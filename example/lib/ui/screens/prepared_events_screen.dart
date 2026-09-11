import 'dart:convert';

import 'package:carrotquest_sdk/carrotquest_sdk.dart';
import 'package:flutter/material.dart';

import '../widgets/settings_ui.dart';

class _PreparedEvent {
  const _PreparedEvent(this.name, [this.params]);

  final String name;
  final Map<String, String>? params;
}

const _events = [
  _PreparedEvent('Открыл приложение'),
  _PreparedEvent('Нажал на кнопку', {'button_id': 'main_cta'}),
  _PreparedEvent('Оформил заказ', {'order_id': '12345', 'amount': '1990'}),
  _PreparedEvent('Зарегистрировался'),
  _PreparedEvent('Добавил в корзину', {'product_id': '42', 'price': '499'}),
  _PreparedEvent('Кликнул по ссылке', {'url': 'https://google.com'}),
];

class PreparedEventsScreen extends StatelessWidget {
  const PreparedEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заготовленные события')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const SectionHeader('Нажмите для отправки'),
          SettingsGroup(
            children: [
              for (final event in _events)
                ListTile(
                  title: Text(event.name),
                  subtitle: event.params == null
                      ? null
                      : Text(jsonEncode(event.params)),
                  onTap: () => _send(context, event),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _send(BuildContext context, _PreparedEvent event) async {
    try {
      await Carrot.trackEvent(event.name, params: event.params);
      if (context.mounted) showSnack(context, 'Отправлено: ${event.name}');
    } catch (e) {
      if (context.mounted) showSnack(context, 'Ошибка: $e');
    }
  }
}
