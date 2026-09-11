# carrotquest_sdk — пример использования

Полное demo-приложение лежит в каталоге [`example/`](https://github.com/carrotquest/flutter-sdk/tree/master/example) репозитория. Ниже — ключевые сценарии из него.

## Инициализация

```dart
import 'package:carrotquest_sdk/carrotquest_sdk.dart';

await Carrot.setup(apiKey, appGroup: 'group.your.app'); // appGroup нужен только на iOS
```

Как это сделано в примере: [`lib/app.dart`](https://github.com/carrotquest/flutter-sdk/blob/master/example/lib/app.dart). Ключи в примере не хранятся в коде, а передаются через `--dart-define-from-file` — см. [`lib/app_config.dart`](https://github.com/carrotquest/flutter-sdk/blob/master/example/lib/app_config.dart).

## Авторизация пользователя

```dart
final carrotId = await Carrot.auth(userId, userAuthKey: userAuthKey);
// или с хэшем, вычисленным на вашем сервере:
final carrotId = await Carrot.auth(userId, userHash: hash);

await Carrot.logOut();
```

Форма логина: [`lib/ui/sheets/login_sheet.dart`](https://github.com/carrotquest/flutter-sdk/blob/master/example/lib/ui/sheets/login_sheet.dart).

## Чат

```dart
await Carrot.openChat();

Carrot.getUnreadConversationsCountStream().listen((count) {
  // обновить бейдж
});

await Carrot.setTheme(CarrotTheme.dark); // light, dark, fromDevice, fromWeb
```

## События и трекинг экранов

```dart
await Carrot.trackEvent('Оформил заказ', params: {'order_id': '12345', 'amount': '1990'});
await Carrot.trackScreen('CatalogScreen');
```

Экраны примера: [`lib/ui/screens/prepared_events_screen.dart`](https://github.com/carrotquest/flutter-sdk/blob/master/example/lib/ui/screens/prepared_events_screen.dart), [`custom_events_screen.dart`](https://github.com/carrotquest/flutter-sdk/blob/master/example/lib/ui/screens/custom_events_screen.dart), [`screen_tracking_screen.dart`](https://github.com/carrotquest/flutter-sdk/blob/master/example/lib/ui/screens/screen_tracking_screen.dart).

## Свойства пользователя

```dart
await Carrot().setUserProperty(CarrotUserProperty(property: CarrotProperty.email, value: 'user@example.com'));
await Carrot().setUserProperty(EcommerceUserProperty(property: EcommerceProperty.cart_amount, value: '1990'));
await Carrot().setUserProperty(UserProperty(name: 'plan', value: 'pro'));
```

Экран примера: [`lib/ui/screens/user_properties_screen.dart`](https://github.com/carrotquest/flutter-sdk/blob/master/example/lib/ui/screens/user_properties_screen.dart).

## Push-уведомления (Firebase Cloud Messaging)

```dart
final token = await FirebaseMessaging.instance.getToken();
await Carrot.sendFcmToken(token!);

FirebaseMessaging.onMessage.listen((message) {
  if (Carrot.isCarrotQuestPush(message.data)) {
    Carrot.sendFirebasePushNotification(message.data);
  }
});
```

Полная связка, включая фоновый обработчик: [`lib/push/fcm_service.dart`](https://github.com/carrotquest/flutter-sdk/blob/master/example/lib/push/fcm_service.dart).

## UTM-метки из диплинков

```dart
Carrot.trackUtm(uri.toString());
```

Получение диплинков через `app_links` и передача в SDK: [`lib/app.dart`](https://github.com/carrotquest/flutter-sdk/blob/master/example/lib/app.dart).

## Запуск примера

Инструкция по ключам, Firebase-конфигу и проверке диплинков — в [`example/README.md`](https://github.com/carrotquest/flutter-sdk/blob/master/example/README.md).
