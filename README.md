# Carrot quest для Flutter
SDK CarrotQuest для Flutter позволяет разработчикам интегрировать сервисы [CarrotQuest](https://developers.carrotquest.io/) в свои приложения Flutter. Данная документация содержит подробное руководство по использованию методов SDK.
## Содержание

- [Установка](#install)
- [Инициализация](#init)
- [Авторизация пользователей](#auth)
- [Свойства пользователей и события ](#properties)
- [Чат с оператором](#chat)
- [Уведомления](#notifications)
- [Дополнительная информация об iOS](#additional_ios)

<a name="install"></a>
## Установка

Команда для установки пакета через Flutter:

```shell
 $ flutter pub add carrotquest_sdk
```

Это добавит в pubspec.yaml вашего проекта строку следующего содержания (и запустит `flutter pub get`):

```yaml
dependencies:
  carrotquest_sdk: <latest-version>
```

### Импортирование
В Dart коде, добавьте следующую строку:

```dart
import 'package:carrotquest_sdk/carrotquest_sdk.dart';
```

### Дополнительная настройка для Android
В Android-чатси вашего проекта нужно включить поддержку multiDex. Для этого в файл `build.gradle` добавьте строку:
```groovy
android {
    ...
    defaultConfig {
        ...
        multiDexEnabled true
    }
}
```

<a name="init"></a>
## Инициализация
Для работы с Carrot quest для Flutter вам понадобится API Key и User Auth Key. Вы можете найти эти ключи на вкладке Настройки > Разработчикам:  
![Api keys](https://github.com/carrotquest/android-sdk/blob/carrotquest/img/carrot_api_keys.png?raw=true)

Для инициализации Carrot quest вам нужно выполнить следующий код в методе `onCreate()` вашего приложения:

```dart  
Carrot.setup(apiKey, appId);  
```

На Android у Вас может возникнуть ошибка при попытке инициализации SDK. Для избежания таких случаев, убедитесь что проверили статус инициализации SDK:

```dart  
final isInit = await Carrot.isInit();
if (isInit) return;
```

<a name="auth"></a>
## Авторизация пользователей

Если в вашем приложении присутствует авторизация пользователей, вы можете передать id пользователя в Carrot. Существует два способа авторизации.

Напрямую передать userAuthKey
```dart  
Carrot.auth(userId, userAuthKey: _userAuthKey)  
```

Передать hash генерируемый у вас на бэке
```dart  
Carrot.auth(id, userHash: _hash)
```

Чтобы сменить пользователя, нужно вызвать метод логаута:
```dart  
Carrot.logOut();  
```

<a name="properties"></a>
## Свойства пользователей и события

Вы можете установить необходимые свойства пользователя с помощью
```dart  
 Carrot.setUserProperty(userProperty);  
```

Для описания свойств пользователя используйте класс `UserProperty`
```dart  
 UserProperty(String key, String value);  
```

`Внимание!`  
Поле `key` не может начинаться с символа `$`.


Для установки [системных свойств](https://carrotquest.io/developers/props#_4) реализовано 2 класса `CarrotUserProperty` и `EcommerceUserProperty`.


Для отслеживания событий используйте метод `trackEvent()`. Вы также можете указать дополнительные параметры для события
```dart  
 Carrot.trackEvent(String event, {Map<String, String>? params});  
```
Вы можете получить количество диалогов, содержащих непрочитанные сообщения
```dart  
 Carrot.getUnreadConversationsCount();  
```
Также можно подписаться на изменения количества таких диалогов
```dart  
 Carrot.getUnreadConversationsCountStream();  
```
<a name="chat"></a>
## Чат с оператором
Вы можете дать пользователю мобильного приложения возможность перейти в чат с оператором из любого места. Для этого используете
```dart  
 Carrot.openChat();  
```

Получить количество непрочитанных диалогов и список их ID:

```dart  
 Carrot.getUnreadConversationsCount();  
```

Подписаться на список непрочитанных диалогов:

```dart  
 Carrot.getUnreadConversationsCountStream();  
```

<a name="notifications"></a>

## Уведомления
Для работы с push-уведомлениями SDK использует сервис Firebase Cloud Messaging. В связи с этим необходимо получить ключ и отправить его в Carrot. Вы можете найти поле для ввода ключа на вкладке Настройки > Разработчикам. Процесс настройки сервиса Firebase Cloud Messaging описан [здесь](https://firebase.google.com/docs/cloud-messaging?authuser=0)

Для работы push-уведомлений вам необходимо выполнить следующие шаги:
1. Если вы еще не используете в своем проекте FCM, то добавьте в свой проект зависимости `firebase_core` и  `firebase_messaging`:
      ```yaml
      dependencies:
        flutter:
          sdk: flutter
        
        # Firebase
        firebase_core: ^2.15.0
        firebase_messaging: ^14.6.5
      ```
      И после этого в каталоге проекта Flutter выполните следующую команду, чтобы запустить рабочий процесс настройки приложения:
      ```console
      flutterfire configure
      ```
      Более подробно о процессе установки FCM в свой Flutter-проект можно узнать в официальной  [документации](https://firebase.google.com/docs/flutter/setup?platform=android) 

2. В файле `main.dart` перед объявления метода `main()` добавить (или модифицировать, если вы уже используете FCM у себя в проекте) хэндлер для пушей, которые будет приходить в фоне, внутри которого нужно прокинуть пуши в Carrot SDK, чтобы они корректно отобразились на устройстве:
      ```dart
      @pragma('vm:entry-point')
      Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      
        bool isCarrotPush = Carrot.isCarrotQuestPush(message.data);
        if (isCarrotPush) {
          Carrot.sendFirebasePushNotification(message.data);
        }
      }
      ```

3. После инициализации Carrot SDK нужно отправить в сервис token от Firebase, используя метод `Carrot.sendFcmToken(token)`, задать для Firebase ранее написанный хэндлер для уведомлений, которые будут приходить при закрытом приложении, и написать листенер для уведомлений, которые будут приходить в открытое приложение. Например, так:
      ```dart
      Future<void> _initCarrotSdk() {
        return Carrot.setup(_appId, _apiKey).then((value) async {
      	await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      	await FirebaseMessaging.instance.setAutoInitEnabled(true);
      
      	FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      	String? token = await FirebaseMessaging.instance.getToken();
      
      	if (token != null) {
      	  await Carrot.sendFcmToken(token);
      
            FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
              bool isCarrotPush = Carrot.isCarrotQuestPush(message.data);
              if (isCarrotPush) {
                Carrot.sendFirebasePushNotification(message.data);
              }
            });
      	}
        });
      }
      ```
4. Чтобы получать уведомления на устройства Apple, нужно открыть iOS часть своего проекта и написать код запроса на разрешения показа уведмолений. Для этого откройте AppDelegate и в функцию application допишите следущий код:
      ```swift
      override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      	GeneratedPluginRegistrant.register(withRegistry: self)
      
      	if #available(iOS 10.0, *) {
      		// For iOS 10 display notification (sent via APNS)
      		UNUserNotificationCenter.current().delegate = self
      
      		let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      		UNUserNotificationCenter.current().requestAuthorization(
      			options: authOptions,
      			completionHandler: { _, _ in }
      		)
      	} else {
      		let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      		application.registerUserNotificationSettings(settings)
      	}
      
      	application.registerForRemoteNotifications()
      	return super.application(application, didFinishLaunchingWithOptions: launchOptions)
      }
      ```
5. Далее, вам необходимо вставить следующий код целиком. 
    ```swift
    import CarrotSDK
    
    extension AppDelegate {
    
        private func getAppGroup() -> String {
            return <group_id>
        }
        
        override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            let notificationService = CarrotNotificationService.shared
            if notificationService.canHandle(notification) {
                notificationService.show(notification, appGroudDomain: self.getAppGroup(), completionHandler: completionHandler)
            } else {
                // Логика для пользовательских уведомлений
            }
        }
        
        override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            let notificationService = CarrotNotificationService.shared
            if notificationService.canHandle(response) {
                notificationService.clickNotification(notificationResponse: response, appGroudDomain: self.getAppGroup())
            } else {
                // Логика для пользовательских уведомлений
            }
        }
    }
    ```
6. Обратите внимание на строчку с group_id. По идее, этот пункт является не обязательным, и group_id в можно не передавать вовсе. Дело в том, что мы используем 2 канала доставки сообщений, поэтому в некоторых случаях уведомления могут дублироваться. Например: при выходе из приложения, или при очень быстром удалении уведомления, возможно получение повтороного уведомления. Если вы не замечаете дублирование сообщений, можете перейти сразу к шагу 11. Для предотвращения такого поведения нужно создать Notification Service Extension. В Xcode, в списке файлов выберите свой проект, а затем File/New/Target/Notification Service Extension. Так же, важно установить версию iOS для Notification Service Extension такую же, как у самого приложения.
7. После чего необходимо зарегистрировать AppGroup в [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list/applicationGroup). Identifier App Group должен быть уникальным, и начинаться на "group." иначе Xcode его не примет. 
8. Теперь необходимо добавить Identifier в Xcode:

1) В списке файлов выберите свой проект. 
2) В списке targets выберете пункт с именем вашего проекта. 
3) Во вкладке "Singing & Capabitities" нажмите на "+ Capability". 
4) В выпадающем списке найдите найдите и выберите App Group.
5) На вкладке появится пустой список для идентификаторов App Group. Добавте туда Identifier, который зарегистрировали в Apple Developer Portal ранее. 
6) Вернитесь к списку Targets. Аналогичным образом добавте App Group к вашему Notification Service Extension. 

![AppGroup](https://raw.githubusercontent.com/carrotquest/ios-sdk/dashly/assets/AppGroup.png)

8. Внесите изменения в метод инициализирующий библиотеку:

    ```dart
    Carrot.setup(apiKey, appId, appGroup: <group_id>));
    ```

9. Теперь нужно добавить логику в ваш Notification Service Extension. В списке файлов, должна была появиться новая папка с именем вашего Notification Service Extension. Добавте код в файл NotificationService.swift:

    ```swift
    import UserNotifications
    import CarrotSDK
    
    class NotificationService: CarrotNotificationServiceExtension {
        override func setup() {
            self.domainIdentifier = <group_id>
        }
        override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
            <ваша логика>
            super.didReceive(request, withContentHandler: contentHandler) 
        }
    }
    ```

10. Обновите ваш pod файл, добавьте:

    ```ruby
    target 'NotificationService' do
     	inherit! :search_paths
    end
    ```

11. Для Android устройств можно поменять иконку у уведомлений. Для этого положите в Android часть своего проекта нужную вам иконку с названием `ic_cqsdk_notification.xml`. 

После этого основная настройка push-уведомлений закончена. 

<a name="additional_ios"></a>
## Дополнительная информация об iOS

Чтобы светлая тема правильно выглядела, вам нужно разрешить контроллерам управлять цветом статус-бара. Для этого откройте нативную iOS часть своего проекта и в файле info.plist в строчке под названием UIViewControllerBasedStatusBarAppearance поменяте false на true. Если вы открываете через Xcode, тогда эта строка называется "View controller-based status Bar appearance" и имеет значение NO. Вам необходимо поставить значение на YES. 