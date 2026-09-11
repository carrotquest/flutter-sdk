import 'package:carrotquest_sdk/carrotquest_sdk.dart';
import 'package:flutter/material.dart';

import '../../app_config.dart';
import '../../get_hash_use_case.dart';

/// Открывает форму логина и возвращает текст результата для SnackBar.
Future<String?> showLoginSheet(BuildContext context, {required bool byHash}) {
  return showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (_) => _LoginSheet(byHash: byHash),
  );
}

class _LoginSheet extends StatefulWidget {
  const _LoginSheet({required this.byHash});

  final bool byHash;

  @override
  State<_LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<_LoginSheet> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final userId = _controller.text.trim();
    setState(() => _isLoading = true);

    String message;
    try {
      final String? carrotId;
      if (widget.byHash) {
        final hash = await getHash(userId);
        carrotId = await Carrot.auth(userId, userHash: hash);
      } else {
        carrotId = await Carrot.auth(
          userId,
          userAuthKey: AppConfig.userAuthKey,
        );
      }
      message = 'CarrotId: ${carrotId ?? 'null'}';
    } catch (e) {
      message = 'Ошибка авторизации: $e';
    }

    if (mounted) Navigator.of(context).pop(message);
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _controller.text.trim().isNotEmpty && !_isLoading;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.byHash ? 'Логин по хэшу' : 'Логин',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              labelText: 'User ID',
              hintText: 'email, телефон или ваш внутренний id',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => canSubmit ? _submit() : null,
          ),
          if (widget.byHash) ...[
            const SizedBox(height: 8),
            Text(
              'Хэш должен вычисляться на вашем сервере. '
              'Здесь используется заглушка getHash().',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: canSubmit ? _submit : null,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Войти'),
          ),
        ],
      ),
    );
  }
}
