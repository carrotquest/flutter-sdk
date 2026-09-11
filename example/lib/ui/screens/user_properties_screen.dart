import 'package:carrotquest_sdk/carrotquest_sdk.dart';
import 'package:carrotquest_sdk/user_property/carrot_user_property.dart';
import 'package:carrotquest_sdk/user_property/ecommerce_user_property.dart';
import 'package:carrotquest_sdk/user_property/user_property.dart';
import 'package:flutter/material.dart';

import '../widgets/settings_ui.dart';

/// Свойства пользователя: Carrot().setUserProperty(UserProperty).
///
/// Системные свойства ($name, $email, $phone) и ecommerce-свойства ($cart_amount
/// и т.д.) удобно задавать через [CarrotUserProperty] и [EcommerceUserProperty],
/// произвольные — через [UserProperty].
class UserPropertiesScreen extends StatefulWidget {
  const UserPropertiesScreen({super.key});

  @override
  State<UserPropertiesScreen> createState() => _UserPropertiesScreenState();
}

class _UserPropertiesScreenState extends State<UserPropertiesScreen> {
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();
  final _sent = <String>[];

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  UserProperty _buildProperty(String key, String value) {
    final bareKey = key.startsWith('\$') ? key.substring(1) : key;
    for (final property in CarrotProperty.values) {
      if (property.name == bareKey) {
        return CarrotUserProperty(property: property, value: value);
      }
    }
    for (final property in EcommerceProperty.values) {
      if (property.name == bareKey) {
        return EcommerceUserProperty(property: property, value: value);
      }
    }
    return UserProperty(name: key, value: value);
  }

  Future<void> _send() async {
    final property = _buildProperty(
      _keyController.text.trim(),
      _valueController.text,
    );
    try {
      await Carrot().setUserProperty(property);
    } catch (e) {
      if (mounted) showSnack(context, 'Ошибка: $e');
      return;
    }
    if (!mounted) return;
    showSnack(context, 'Отправлено: ${property.name}');
    setState(() {
      _sent.insert(
        0,
        '${property.runtimeType}: ${property.name} = ${property.value}',
      );
      _keyController.clear();
      _valueController.clear();
    });
  }

  void _setKey(String key) {
    setState(() => _keyController.text = key);
  }

  @override
  Widget build(BuildContext context) {
    final canSend = _keyController.text.trim().isNotEmpty &&
        _valueController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Свойства пользователя')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const SectionHeader('Свойство'),
          TextField(
            controller: _keyController,
            decoration: const InputDecoration(
              labelText: 'Ключ',
              hintText: 'например, plan',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _valueController,
            decoration: const InputDecoration(
              labelText: 'Значение',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SectionHeader('Системные свойства'),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final property in CarrotProperty.values)
                ActionChip(
                  label: Text('\$${property.name}'),
                  onPressed: () => _setKey('\$${property.name}'),
                ),
            ],
          ),
          const SectionHeader('Ecommerce-свойства'),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final property in EcommerceProperty.values)
                ActionChip(
                  label: Text('\$${property.name}'),
                  onPressed: () => _setKey('\$${property.name}'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Отправить свойство'),
            onPressed: canSend ? _send : null,
          ),
          if (_sent.isNotEmpty) ...[
            const SectionHeader('Отправлено за сессию'),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in _sent) MonospaceText(entry),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
