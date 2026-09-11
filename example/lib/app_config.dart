/// Ключи Carrot quest не хранятся в коде: они подставляются при запуске через
///   flutter run --dart-define-from-file=config/secrets.json
/// Шаблон — config/secrets.example.json, подробности — в README.md.
class AppConfig {
  static const String apiKey = String.fromEnvironment('CARROT_API_KEY');

  static const String userAuthKey =
      String.fromEnvironment('CARROT_USER_AUTH_KEY');

  /// App Group нужен только на iOS: общее хранилище приложения
  /// и Notification Service Extension.
  static const String appGroup = String.fromEnvironment(
    'CARROT_APP_GROUP',
    defaultValue: 'group.cq.flutterSdkExample',
  );

  /// URL-схема для проверки трекинга UTM-меток, настроена в нативных проектах
  /// (android/app/src/main/AndroidManifest.xml и ios/Runner/Info.plist).
  static const String deeplinkScheme = 'carrotexample';

  static bool get isConfigured => apiKey.isNotEmpty;

  static String mask(String value) {
    if (value.isEmpty) return 'не задан';
    if (value.length <= 10) return '••••••';
    return '${value.substring(0, 6)}…${value.substring(value.length - 4)}';
  }
}
