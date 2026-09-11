import 'package:flutter/material.dart';

import 'app.dart';

/// Demo-приложение carrotquest_sdk.
///
/// Структура:
///   app.dart                 — инициализация SDK, диплинки (UTM), тема, счётчик непрочитанных
///   app_config.dart          — ключи из --dart-define-from-file=config/secrets.json
///   push/fcm_service.dart    — Firebase Cloud Messaging → Carrot.sendFcmToken / sendFirebasePushNotification
///   ui/screens/              — главный экран и разделы: события, трекинг экранов, свойства пользователя
///   ui/sheets/, ui/dialogs/  — логин, FCM токен
void main() {
  runApp(const CarrotExampleApp());
}
