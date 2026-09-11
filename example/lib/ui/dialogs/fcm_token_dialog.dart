import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/settings_ui.dart';

Future<void> showFcmTokenDialog(BuildContext context, String token) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('FCM токен'),
      content: SingleChildScrollView(child: MonospaceText(token)),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: token));
            if (context.mounted) showSnack(context, 'Скопировано');
          },
          child: const Text('Копировать'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
