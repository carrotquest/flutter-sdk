import 'package:carrotquest_sdk/carrotquest_sdk.dart';
import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../../push/fcm_service.dart';
import '../dialogs/fcm_token_dialog.dart';
import '../sheets/login_sheet.dart';
import '../widgets/settings_ui.dart';
import 'custom_events_screen.dart';
import 'prepared_events_screen.dart';
import 'screen_tracking_screen.dart';
import 'user_properties_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({
    super.key,
    required this.unreadCount,
    required this.lastDeeplinkInfo,
    required this.darkTheme,
    required this.onDarkThemeChange,
    required this.isLoggingOut,
    required this.onLogout,
  });

  final int unreadCount;
  final String? lastDeeplinkInfo;
  final bool darkTheme;
  final ValueChanged<bool> onDarkThemeChange;
  final bool isLoggingOut;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrot quest SDK'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Конфигурация',
            onPressed: () => _showConfigDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          if (!AppConfig.isConfigured) const _ConfigWarning(),
          const SectionHeader('Основа'),
          SettingsGroup(
            dividerIndent: 56,
            children: [
              ListTile(
                leading: Icon(Icons.chat_outlined, color: colors.primary),
                title: Text('Открыть чат',
                    style: TextStyle(color: colors.primary)),
                trailing: unreadCount > 0 ? _UnreadBadge(unreadCount) : null,
                onTap: Carrot.openChat,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Тёмная тема'),
                subtitle: const Text('Carrot.setTheme'),
                value: darkTheme,
                onChanged: onDarkThemeChange,
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Логин'),
                subtitle: const Text('Carrot.auth с User Auth Key'),
                trailing: const Chevron(),
                onTap: () => _login(context, byHash: false),
              ),
              ListTile(
                leading: const Icon(Icons.key_outlined),
                title: const Text('Логин по хэшу'),
                subtitle: const Text('Carrot.auth с userHash'),
                trailing: const Chevron(),
                onTap: () => _login(context, byHash: true),
              ),
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('Свойства пользователя'),
                trailing: const Chevron(),
                onTap: () => _push(context, const UserPropertiesScreen()),
              ),
              ListTile(
                enabled: !isLoggingOut,
                leading: Icon(Icons.logout, color: colors.error),
                title: Text('Выйти', style: TextStyle(color: colors.error)),
                subtitle: const Text('Carrot.logOut'),
                onTap: () async {
                  await onLogout();
                  if (context.mounted) showSnack(context, 'Теперь вы аноним');
                },
              ),
            ],
          ),
          if (lastDeeplinkInfo != null) ...[
            const SectionHeader('Диплинк'),
            SettingsGroup(
              children: [
                ListTile(
                  leading: const Icon(Icons.link),
                  title: const Text('Последний диплинк'),
                  subtitle: Text(lastDeeplinkInfo!),
                ),
              ],
            ),
          ],
          const SectionHeader('События'),
          SettingsGroup(
            dividerIndent: 56,
            children: [
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: const Text('Заготовленные события'),
                trailing: const Chevron(),
                onTap: () => _push(context, const PreparedEventsScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Кастомные события'),
                trailing: const Chevron(),
                onTap: () => _push(context, const CustomEventsScreen()),
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart_outlined),
                title: const Text('Трекинг экранов'),
                trailing: const Chevron(),
                onTap: () => _push(context, const ScreenTrackingScreen()),
              ),
            ],
          ),
          const SectionHeader('Пуши'),
          SettingsGroup(
            dividerIndent: 56,
            children: [
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: const Text('Разрешить уведомления'),
                subtitle: const Text('Запросить разрешение и отправить токен'),
                onTap: () => _requestNotifications(context),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_outlined),
                title: const Text('FCM токен'),
                subtitle: const Text('Показать и скопировать текущий токен'),
                trailing: const Chevron(),
                onTap: () => _showFcmToken(context),
              ),
              ListTile(
                leading: const Icon(Icons.notifications_off_outlined),
                title: const Text('Отписаться от пушей'),
                subtitle: const Text('pushNotificationsUnsubscribe'),
                onTap: () => _unsubscribe(
                    context, Carrot.pushNotificationsUnsubscribe),
              ),
              ListTile(
                leading: const Icon(Icons.campaign_outlined),
                title: const Text('Отписаться от кампаний'),
                subtitle: const Text('pushCampaignsUnsubscribe'),
                onTap: () =>
                    _unsubscribe(context, Carrot.pushCampaignsUnsubscribe),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _login(BuildContext context, {required bool byHash}) async {
    final message = await showLoginSheet(context, byHash: byHash);
    if (message != null && context.mounted) showSnack(context, message);
  }

  Future<void> _requestNotifications(BuildContext context) async {
    try {
      final granted = await FcmService.requestPermission();
      if (granted) await FcmService.init();
      if (!context.mounted) return;
      showSnack(
        context,
        granted
            ? 'Уведомления разрешены, токен отправлен'
            : 'Уведомления запрещены',
      );
    } catch (e) {
      if (context.mounted) showSnack(context, 'Ошибка: $e');
    }
  }

  Future<void> _showFcmToken(BuildContext context) async {
    String? token;
    try {
      token = await FcmService.getToken();
    } catch (e) {
      if (context.mounted) showSnack(context, 'Не удалось получить токен: $e');
      return;
    }
    if (!context.mounted) return;
    if (token == null || token.isEmpty) {
      showSnack(context, 'Токен ещё не получен');
      return;
    }
    showFcmTokenDialog(context, token);
  }

  Future<void> _unsubscribe(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      if (context.mounted) showSnack(context, 'Запрос на отписку отправлен');
    } catch (e) {
      if (context.mounted) showSnack(context, 'Ошибка: $e');
    }
  }

  void _showConfigDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Конфигурация'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow('API key', AppConfig.mask(AppConfig.apiKey)),
            _InfoRow('User Auth Key', AppConfig.mask(AppConfig.userAuthKey)),
            const _InfoRow('App Group (iOS)', AppConfig.appGroup),
            const _InfoRow('URL-схема диплинков', '${AppConfig.deeplinkScheme}://'),
            const SizedBox(height: 12),
            Text(
              'Ключи задаются при запуске:\n'
              'flutter run --dart-define-from-file=config/secrets.json',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.outline),
          ),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge(this.count);

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('$count', style: TextStyle(color: colors.onPrimary)),
    );
  }
}

class _ConfigWarning extends StatelessWidget {
  const _ConfigWarning();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(top: 8),
      color: colors.errorContainer,
      child: ListTile(
        leading: Icon(Icons.warning_amber_rounded, color: colors.error),
        title: Text(
          'Ключи Carrot quest не заданы',
          style: TextStyle(color: colors.onErrorContainer),
        ),
        subtitle: Text(
          'SDK не инициализирован. Запустите приложение командой\n'
          'flutter run --dart-define-from-file=config/secrets.json',
          style: TextStyle(color: colors.onErrorContainer),
        ),
      ),
    );
  }
}
