import 'package:flutter/widgets.dart';
import 'package:patrol/patrol.dart';

abstract class BaseTestScenario {
  /// [$] это [PatrolIntegrationTester]
  /// [next] это [BaseTestScenario]
  const BaseTestScenario(this.$, {required this.next});

  /// [next] это [BaseTestScenario]
  final BaseTestScenario? next;
  final PatrolIntegrationTester $;

  /// [run] непосредственно запускает сам сценарий
  Future<bool> run();

  /// [waitAndCheckValid] проверяет валидный ли вообще сценарий и можно ли его запускать
  Future<bool> waitAndCheckValid();

  /// [startFlow] запускает флоу
  Future<void> startFlow() async {
    try {
      final isVisible = await waitAndCheckValid();
      if (isVisible) {
        await run();
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    } finally {
      if (next != null) {
        await next!.startFlow();
      }
    }
  }
}