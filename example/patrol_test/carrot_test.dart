import 'package:carrotquest_sdk_example/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'flows/open_chat_scenario.dart';

void main() {
  patrolTest(
    'Can press chat button',
    ($) async {
      await $.pumpWidgetAndSettle(const MyApp());
      // Ждем инита sdk
      await Future.delayed(const Duration(seconds: 10));

      final openChatTest = OpenChatFlow($, next: null);
      await openChatTest.startFlow();
    },
  );
}