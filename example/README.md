# Demo-приложение carrotquest_sdk

Готовое приложение, которое показывает все возможности SDK на практике: инициализацию, авторизацию, свойства и события, чат, push-уведомления и трекинг UTM-меток.

Чтобы понять, как пользоваться SDK, чаще всего достаточно просто посмотреть код — главный файл [`lib/main.dart`](lib/main.dart).

## Запуск

Если вы хотите не только почитать, но и запустить приложение, понадобятся ваши собственные ключи Carrot quest и конфиг Firebase: в репозитории их нет — лежат только шаблоны `*.example`.

1. Создайте рабочие файлы из шаблонов:

   ```bash
   cd example
   ./setup.sh
   ```

   Скрипт создаст:
   - `config/secrets.json` — ключи Carrot quest;
   - `lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `ios/GoogleService-Info.plist`, `ios/firebase_app_id_file.json` — конфиг Firebase.

2. Впишите свои значения в `config/secrets.json`:

   ```json
   {
     "CARROT_API_KEY": "<ваш API Key>",
     "CARROT_USER_AUTH_KEY": "<ваш User Auth Key>",
     "CARROT_APP_GROUP": "group.cq.flutterSdkExample"
   }
   ```

   API Key и User Auth Key находятся на вкладке **Настройки → Разработчикам** в Carrot quest.

3. Подставьте свой Firebase-конфиг — проще всего командой `flutterfire configure` (перезапишет файлы из шага 1), либо отредактируйте созданные файлы вручную.

4. Запустите приложение, передав файл с ключами:

   ```bash
   flutter run --dart-define-from-file=config/secrets.json
   ```

   В VS Code уже есть готовые конфигурации запуска `example` / `example (profile mode)` / `example (release mode)` (см. [`../.vscode/launch.json`](../.vscode/launch.json)).

> Ключи читаются через `String.fromEnvironment(...)` (см. [`lib/main.dart`](lib/main.dart)), поэтому без `--dart-define-from-file` поля останутся пустыми и SDK не инициализируется.

## Проверка трекинга UTM-меток

Приложение слушает входящие deeplink-и (через пакет [`app_links`](https://pub.dev/packages/app_links)) и передаёт ссылку в `Carrot.trackUtm(...)` — отдельно для холодного старта и для уже запущенного приложения. Настроена кастомная URL-схема `carrotexample` (см. `android/app/src/main/AndroidManifest.xml` и `ios/Runner/Info.plist`).

Открыть приложение по ссылке с UTM-метками:

```bash
# Android (приложение уже запущено)
adb shell am start -a android.intent.action.VIEW \
  -d "carrotexample://open?utm_source=google&utm_medium=cpc&utm_campaign=spring_sale"

# iOS (симулятор)
xcrun simctl openurl booted \
  "carrotexample://open?utm_source=google&utm_medium=cpc&utm_campaign=spring_sale"
```

После этого в карточке пользователя в Carrot quest заполнятся системные свойства `$utm_source`, `$utm_medium`, `$utm_campaign`, `$utm_term`, `$utm_content`.
