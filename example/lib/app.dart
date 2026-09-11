import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:carrotquest_sdk/carrotquest_sdk.dart';
import 'package:flutter/material.dart';

import 'app_config.dart';
import 'push/fcm_service.dart';
import 'ui/screens/main_screen.dart';

class CarrotExampleApp extends StatefulWidget {
  const CarrotExampleApp({super.key});

  @override
  State<CarrotExampleApp> createState() => _CarrotExampleAppState();
}

class _CarrotExampleAppState extends State<CarrotExampleApp> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  StreamSubscription<int>? _unreadSubscription;

  int _unreadCount = 0;
  String? _lastDeeplinkInfo;
  bool _darkTheme = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _initDeeplinks();
    _initSdk();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _unreadSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initSdk() async {
    if (!AppConfig.isConfigured) {
      debugPrint('CARROT_API_KEY is empty. '
          'Run with --dart-define-from-file=config/secrets.json');
      return;
    }

    try {
      final ok = await Carrot.setup(
        AppConfig.apiKey,
        appGroup: AppConfig.appGroup,
      );
      if (!ok) {
        debugPrint('Carrot.setup returned false');
        return;
      }
    } catch (e) {
      debugPrint('Carrot.setup error: $e');
      return;
    }

    _unreadSubscription =
        Carrot.getUnreadConversationsCountStream().listen((count) {
      if (mounted) setState(() => _unreadCount = count);
    });

    try {
      await FcmService.init();
    } catch (e) {
      debugPrint('FCM init error: $e');
    }
  }

  /// [Carrot.trackUtm] принимает ссылку, по которой открыли приложение, и сам
  /// извлекает из неё UTM-метки. Вызывать можно ещё до завершения [Carrot.setup].
  Future<void> _initDeeplinks() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) _handleDeeplink(initialUri);
      _linkSubscription = _appLinks.uriLinkStream.listen(_handleDeeplink);
    } catch (e) {
      debugPrint('Deeplinks error: $e');
    }
  }

  void _handleDeeplink(Uri uri) {
    const utmKeys = [
      'utm_source',
      'utm_medium',
      'utm_campaign',
      'utm_term',
      'utm_content',
    ];
    final params = [
      for (final key in utmKeys)
        if (uri.queryParameters[key] != null)
          '$key: ${uri.queryParameters[key]}',
    ];
    setState(() {
      _lastDeeplinkInfo =
          params.isEmpty ? 'Ссылка без UTM:\n$uri' : params.join('\n');
    });

    Carrot.trackUtm(uri.toString());
  }

  void _onDarkThemeChange(bool value) {
    setState(() => _darkTheme = value);
    Carrot.setTheme(value ? CarrotTheme.dark : CarrotTheme.light);
  }

  Future<void> _logOut() async {
    setState(() => _isLoggingOut = true);
    try {
      await Carrot.logOut();
    } catch (e) {
      debugPrint('Log out error: $e');
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carrot quest SDK',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepOrange,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepOrange,
        brightness: Brightness.dark,
      ),
      themeMode: _darkTheme ? ThemeMode.dark : ThemeMode.light,
      home: MainScreen(
        unreadCount: _unreadCount,
        lastDeeplinkInfo: _lastDeeplinkInfo,
        darkTheme: _darkTheme,
        onDarkThemeChange: _onDarkThemeChange,
        isLoggingOut: _isLoggingOut,
        onLogout: _logOut,
      ),
    );
  }
}
