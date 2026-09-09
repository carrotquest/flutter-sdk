import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:carrotquest_sdk/carrotquest_sdk.dart';
import 'package:carrotquest_sdk/user_property/carrot_user_property.dart';
import 'package:carrotquest_sdk/user_property/ecommerce_user_property.dart';
import 'package:carrotquest_sdk/user_property/user_property.dart';
import 'package:carrotquest_sdk_example/get_hash_use_case.dart';
import 'package:carrotquest_sdk_example/firebase_options.dart';
import 'package:carrotquest_sdk_example/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  bool isCarrotPush = Carrot.isCarrotQuestPush(message.data);
  if (isCarrotPush) {
    Carrot.sendFirebasePushNotification(message.data);
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _carrot = Carrot();

  /// Для работы с Carrot quest для Flutter вам понадобится API Key и User Auth Key (либо ранее сгенерированный хэш для авторизации).
  /// Вы можете найти эти данные на вкладке Настройки > Разработчикам.
  ///
  /// Значения НЕ хранятся в коде: они подставляются при запуске через
  ///   flutter run --dart-define-from-file=config/secrets.json
  /// Шаблон — config/secrets.example.json, подробности — в example/README.md.
  final String _apiKey = const String.fromEnvironment('CARROT_API_KEY');
  final String _userAuthKey =
      const String.fromEnvironment('CARROT_USER_AUTH_KEY');

  /// AppGroup - общее хранилище данных для разных приложений одного разработчика.
  /// Он позволяет обменитьвася данными между приложением и Notification Service Extension.
  /// Создать его можно в https://developer.apple.com/account/resources/identifiers/list/applicationGroup
  final String _appGroup = const String.fromEnvironment('CARROT_APP_GROUP',
      defaultValue: 'group.cq.flutterSdkExample');

  int unreadConversationsCount = 0;

  bool _isLoggingOut = false;

  CarrotTheme _theme = CarrotTheme.fromDevice;

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();

    _initDeeplinks();

    _initCarrotSdk().onError((error, stackTrace) {
      debugPrint("$error");
      return false;
    }).then((value) async {
      if (await NotificationService.checkPermissions()) {
        _initFcm();
      }

      Carrot.getUnreadConversationsCountStream().listen((count) {
        unreadConversationsCount = count;
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  /// Отслеживание UTM-меток из ссылок.
  ///
  /// Метод [Carrot.trackUtm] предназначен прежде всего для случая, когда
  /// приложение открывается по диплинку (URL Scheme / Universal Link / App Link).
  /// Передайте в него ссылку, по которой было открыто приложение, — SDK сам
  /// извлечёт из неё UTM-параметры (`utm_source`, `utm_medium`, `utm_campaign`,
  /// `utm_term`, `utm_content`) и сохранит их для текущего пользователя.
  ///
  /// Здесь для получения диплинков используется пакет `app_links`. Метод можно
  /// безопасно вызывать ещё до завершения [Carrot.setup] — SDK обработает метки,
  /// как только будет инициализирован. Чтобы пример действительно открывался по
  /// ссылке, в нативных проектах настроена кастомная URL-схема `carrotexample`
  /// (см. android/app/src/main/AndroidManifest.xml и ios/Runner/Info.plist).
  ///
  /// Проверить можно так:
  ///   Android: adb shell am start -a android.intent.action.VIEW \
  ///     -d "carrotexample://open?utm_source=google&utm_medium=cpc&utm_campaign=spring_sale"
  ///   iOS:     xcrun simctl openurl booted \
  ///     "carrotexample://open?utm_source=google&utm_medium=cpc&utm_campaign=spring_sale"
  Future<void> _initDeeplinks() async {
    // Ссылка, по которой приложение было запущено (холодный старт).
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      Carrot.trackUtm(initialUri.toString());
    }

    // Ссылки, приходящие, пока приложение уже запущено.
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      Carrot.trackUtm(uri.toString());
    });
  }

  Future<void> _logOut() async {
    setState(() => _isLoggingOut = true);
    try {
      await Carrot.trackEvent("Tap button", params: {"Button": "Log out"});
      await Carrot.logOut();
    } catch (e) {
      debugPrint("Log out error: $e");
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  Future<bool> _initCarrotSdk() {
    return Carrot.setup(_apiKey, appGroup: _appGroup);
  }

  void _initFcm() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null && token.isNotEmpty) {
      await Carrot.sendFcmToken(token);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        bool isCarrotPush = Carrot.isCarrotQuestPush(message.data);
        if (isCarrotPush) {
          Carrot.sendFirebasePushNotification(message.data);
        }
      });
    }
  }

  void _requestNotificationsPermission() {
    NotificationService.requestNotificationPermission(context).then((res) {
      if (res) {
        _initFcm();
      }
    });
  }

  /// Auth user
  void _auth(BuildContext con) {
    TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: con,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              right: 32,
              top: 24,
              left: 32,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    hintText: "Input your id (phone, email, etc.)",
                    border: OutlineInputBorder()),
                controller: controller,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  String id = controller.text;

                  if (id.isEmpty) {
                    return;
                  }

                  Carrot.auth(id, userAuthKey: _userAuthKey).then((carrotId) {
                    String message = carrotId ?? "id - null";
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(message),
                    ));
                    Navigator.pop(context);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text("OK"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Auth user by hash
  void _authHash(BuildContext con) {
    TextEditingController controller = TextEditingController();
    showModalBottomSheet(
      context: con,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              right: 32,
              top: 24,
              left: 32,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    hintText: "Input your id (phone, email, etc...)",
                    border: OutlineInputBorder()),
                controller: controller,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  String id = controller.text;

                  if (id.isEmpty) {
                    return;
                  }

                  getHash(id).then((hash) {
                    Carrot.auth(id, userHash: hash).then((carrotId) {
                      String message = carrotId ?? "id - null";
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(message),
                      ));
                      Navigator.pop(context);
                    });
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text("OK"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeSystemProperty(BuildContext con) {
    TextEditingController controller = TextEditingController();
    UserProperty? selectedProp;

    showModalBottomSheet(
      context: con,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        final List<DropdownMenuEntry<UserProperty>> entries =
            <DropdownMenuEntry<UserProperty>>[];

        for (var element in CarrotProperty.values) {
          entries.add(DropdownMenuEntry(
              value: CarrotUserProperty(property: element, value: ""),
              label: element.name));
        }

        return Padding(
          padding: EdgeInsets.only(
              right: 32,
              top: 24,
              left: 32,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownMenu(
                label: const Text("System user property"),
                onSelected: (value) {
                  selectedProp = value;
                },
                dropdownMenuEntries: entries,
              ),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    hintText: "Value", border: OutlineInputBorder()),
                controller: controller,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  if (selectedProp == null) {
                    return;
                  }
                  String valueProperty = controller.text;
                  if (valueProperty.isEmpty) {
                    return;
                  }

                  if (selectedProp is CarrotUserProperty) {
                    _carrot
                        .setUserProperty((selectedProp as CarrotUserProperty)
                            .copyWith(newValue: valueProperty))
                        .then((value) => Navigator.pop(con));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text("OK"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _unsubscribePushNotifications(BuildContext con) {
    showModalBottomSheet(
      context: con,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
                right: 32,
                top: 24,
                left: 32,
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                  onPressed: () {
                    Carrot.pushNotificationsUnsubscribe()
                        .then((value) => Navigator.pop(con))
                        .onError((error, stackTrace) => Navigator.pop(con));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Text("Unsubscribe all push notifications"),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Carrot.pushCampaignsUnsubscribe()
                        .then((value) => Navigator.pop(con))
                        .onError((error, stackTrace) => Navigator.pop(con));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child:
                        const Text("Unsubscribe campaigns push notifications"),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _changeEcommerceProperty(BuildContext con) {
    TextEditingController controller = TextEditingController();
    UserProperty? selectedProp;

    showModalBottomSheet(
      context: con,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        final List<DropdownMenuEntry<UserProperty>> entries =
            <DropdownMenuEntry<UserProperty>>[];

        for (var element in EcommerceProperty.values) {
          entries.add(DropdownMenuEntry(
              value: EcommerceUserProperty(property: element, value: ""),
              label: element.name));
        }

        return Padding(
          padding: EdgeInsets.only(
              right: 32,
              top: 24,
              left: 32,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownMenu(
                label: const Text("Ecommerce user property"),
                onSelected: (value) {
                  selectedProp = value;
                },
                dropdownMenuEntries: entries,
              ),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    hintText: "Value", border: OutlineInputBorder()),
                controller: controller,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  if (selectedProp == null) {
                    return;
                  }
                  String valueProperty = controller.text;
                  if (valueProperty.isEmpty) {
                    return;
                  }

                  if (selectedProp is EcommerceUserProperty) {
                    _carrot
                        .setUserProperty((selectedProp as EcommerceUserProperty)
                            .copyWith(newValue: valueProperty))
                        .then((value) => Navigator.pop(con));
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text("OK"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _changeCustomProperty(BuildContext con) {
    TextEditingController nameController = TextEditingController();
    TextEditingController valueController = TextEditingController();
    showModalBottomSheet(
      context: con,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              right: 32,
              top: 24,
              left: 32,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    hintText: "Name", border: OutlineInputBorder()),
                controller: nameController,
              ),
              const SizedBox(height: 8),
              TextField(
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                    hintText: "Value", border: OutlineInputBorder()),
                controller: valueController,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  String nameProperty = nameController.text;
                  String valueProperty = valueController.text;
                  if (nameProperty.isEmpty || valueProperty.isEmpty) {
                    return;
                  }

                  _carrot
                      .setUserProperty(UserProperty(
                          name: nameProperty, value: valueProperty))
                      .then((value) => Navigator.pop(con));
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: const Text("OK"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showTrackScreenBottomSheet(BuildContext con) {
    showModalBottomSheet(
      context: con,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: DropdownButton(
            hint: const Text("Select a screen"),
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: "screen1", child: Text("screen1")),
              DropdownMenuItem(value: "screen2", child: Text("screen2")),
              DropdownMenuItem(value: "screen3", child: Text("screen3")),
            ],
            onChanged: (screen) {
              if (screen != null) {
                Carrot.trackScreen(screen);
              }
            },
          ),
        );
      },
    );
  }

  void _showThemeBottomSheet(BuildContext con) {
    showModalBottomSheet(
      context: con,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: CarrotTheme.values.map((theme) {
            return ListTile(
              title: Text(theme.name),
              trailing: theme == _theme ? const Icon(Icons.check) : null,
              onTap: () async {
                await Carrot.setTheme(theme);
                setState(() => _theme = theme);
                if (!context.mounted) return;
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        home: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              title: const Text('Carrot quest SDK example app'),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Carrot.openChat();
              },
              label: Text(unreadConversationsCount.toString()),
              icon: const Icon(Icons.chat),
            ),
            body: Builder(builder: (mContext) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextButton(
                      onPressed: () {
                        _requestNotificationsPermission();
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Enable notifications"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Carrot.trackEvent("Tap button",
                            params: {"Button": "Auth user"});
                        _auth(mContext);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Auth user"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Carrot.trackEvent("Tap button",
                            params: {"Button": "Auth user by hash"});
                        _authHash(mContext);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Auth user by hash"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Carrot.trackEvent("Tap button",
                            params: {"Button": "Change system properties"});
                        _changeSystemProperty(mContext);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Change system properties"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Carrot.trackEvent("Tap button",
                            params: {"Button": "Change ecommerce properties"});
                        _changeEcommerceProperty(mContext);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Change ecommerce properties"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Carrot.trackEvent("Tap button",
                            params: {"Button": "Change custom properties"});
                        _changeCustomProperty(mContext);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Change custom properties"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Carrot.trackEvent("Tap 'show push' button");
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Show push"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Carrot.trackEvent("Tap button", params: {
                          "Button": "Unsubscribe push notifications"
                        });
                        _unsubscribePushNotifications(mContext);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Unsubscribe push notifications"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _showTrackScreenBottomSheet(mContext);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Simulate screen tracking"),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _showThemeBottomSheet(mContext);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text("Change chat theme (${_theme.name})"),
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoggingOut ? null : _logOut,
                      child: const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("Log out"),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            })));
  }
}
