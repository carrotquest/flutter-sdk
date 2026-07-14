#!/usr/bin/env bash
# Подготовка example к запуску: создаёт рабочие конфиги из *.example-шаблонов.
# Нужно один раз перед первым запуском — затем впишите в них свои ключи Carrot quest и Firebase.
set -euo pipefail

cd "$(dirname "$0")"

copy_if_absent() {
  local example="$1" target="$2"
  if [ -f "$target" ]; then
    echo "✓ $target уже существует — пропускаю"
  else
    cp "$example" "$target"
    echo "→ создан $target из $example (впишите реальные значения)"
  fi
}

copy_if_absent config/secrets.example.json                  config/secrets.json
copy_if_absent lib/firebase_options.example.dart            lib/firebase_options.dart
copy_if_absent android/app/google-services.example.json     android/app/google-services.json
copy_if_absent ios/Runner/GoogleService-Info.example.plist  ios/Runner/GoogleService-Info.plist
copy_if_absent ios/GoogleService-Info.example.plist         ios/GoogleService-Info.plist
copy_if_absent ios/firebase_app_id_file.example.json        ios/firebase_app_id_file.json

echo ""
echo "Готово. Дальше:"
echo "  1. Впишите ключи Carrot quest в example/config/secrets.json"
echo "  2. Подставьте реальный Firebase-конфиг демо-проекта:"
echo "       flutterfire configure        (перезапишет файлы выше реальными значениями)"
echo "     либо вручную отредактируйте созданные файлы."
echo "  3. Запуск: flutter run --dart-define-from-file=config/secrets.json"
