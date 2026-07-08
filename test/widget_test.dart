import 'package:flutter_test/flutter_test.dart';

import 'package:cashmate_app/main.dart';

void main() {
  testWidgets('Splash screen shows CashMate branding', (WidgetTester tester) async {
    await tester.pumpWidget(const CashMateApp());

    expect(find.text('CashMate'), findsOneWidget);
    expect(find.text('MULAI'), findsOneWidget);
  });
}
