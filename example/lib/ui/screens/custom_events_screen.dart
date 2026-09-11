import 'dart:convert';

import 'package:carrotquest_sdk/carrotquest_sdk.dart';
import 'package:flutter/material.dart';

import '../widgets/settings_ui.dart';

class CustomEventsScreen extends StatefulWidget {
  const CustomEventsScreen({super.key});

  @override
  State<CustomEventsScreen> createState() => _CustomEventsScreenState();
}

class _ParamRow {
  final key = TextEditingController();
  final value = TextEditingController();

  void dispose() {
    key.dispose();
    value.dispose();
  }
}

class _CustomEventsScreenState extends State<CustomEventsScreen> {
  final _nameController = TextEditingController();
  final _rows = <_ParamRow>[_ParamRow()];

  @override
  void dispose() {
    _nameController.dispose();
    for (final row in _rows) {
      row.dispose();
    }
    super.dispose();
  }

  Map<String, String> _collectParams() {
    return {
      for (final row in _rows)
        if (row.key.text.trim().isNotEmpty) row.key.text.trim(): row.value.text,
    };
  }

  Future<void> _send() async {
    final name = _nameController.text.trim();
    final params = _collectParams();
    try {
      await Carrot.trackEvent(name, params: params.isEmpty ? null : params);
    } catch (e) {
      if (mounted) showSnack(context, 'Ошибка: $e');
      return;
    }
    if (!mounted) return;
    showSnack(context, 'Отправлено: $name');
    setState(() {
      _nameController.clear();
      for (final row in _rows) {
        row.dispose();
      }
      _rows
        ..clear()
        ..add(_ParamRow());
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = _collectParams();
    final canSend = _nameController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Кастомные события')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          const SectionHeader('Событие'),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Название события',
              hintText: 'например, purchase',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SectionHeader('Параметры (необязательно)'),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                if (_rows.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Параметров нет'),
                  ),
                for (var i = 0; i < _rows.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _rows[i].key,
                            decoration: const InputDecoration(
                              labelText: 'ключ',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _rows[i].value,
                            decoration: const InputDecoration(
                              labelText: 'значение',
                              isDense: true,
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Удалить параметр',
                          onPressed: () => setState(() {
                            _rows.removeAt(i).dispose();
                          }),
                        ),
                      ],
                    ),
                  ),
                  if (i < _rows.length - 1) const Divider(height: 1, indent: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Добавить параметр'),
            onPressed: () => setState(() => _rows.add(_ParamRow())),
          ),
          if (params.isNotEmpty) ...[
            const SectionHeader('Будет отправлено'),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: MonospaceText(
                  const JsonEncoder.withIndent('  ').convert(params),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('Отправить событие'),
            onPressed: canSend ? _send : null,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
