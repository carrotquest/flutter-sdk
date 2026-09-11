import 'package:flutter_test/flutter_test.dart';

import 'package:carrotquest_sdk_example/app.dart';

void main() {
  testWidgets('main screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CarrotExampleApp());
    await tester.pump();

    expect(find.text('Carrot quest SDK'), findsOneWidget);
    expect(find.text('Открыть чат'), findsOneWidget);
  });
}
