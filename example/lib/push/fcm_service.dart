import 'package:carrotquest_sdk/carrotquest_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (Carrot.isCarrotQuestPush(message.data)) {
    await Carrot.sendFirebasePushNotification(message.data);
  }
}

/// Связка Firebase Cloud Messaging с Carrot quest SDK.
///
/// SDK нужно передать FCM токен ([Carrot.sendFcmToken]) и каждый входящий пуш,
/// который относится к Carrot quest ([Carrot.isCarrotQuestPush] →
/// [Carrot.sendFirebasePushNotification]).
class FcmService {
  static Future<FirebaseApp>? _firebase;
  static bool _listening = false;

  static Future<void> _ensureFirebase() {
    return _firebase ??= Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  static Future<void> init() async {
    await _ensureFirebase();

    if (!_listening) {
      _listening = true;
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen((message) {
        if (Carrot.isCarrotQuestPush(message.data)) {
          Carrot.sendFirebasePushNotification(message.data);
        }
      });
      FirebaseMessaging.instance.onTokenRefresh.listen(Carrot.sendFcmToken);
    }

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      await Carrot.sendFcmToken(token);
    }
  }

  static Future<String?> getToken() async {
    await _ensureFirebase();
    return FirebaseMessaging.instance.getToken();
  }

  static Future<bool> requestPermission() async {
    await _ensureFirebase();
    final settings = await FirebaseMessaging.instance.requestPermission();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }
}
