import 'package:flutter_test/flutter_test.dart';
import 'package:scan_in/main.dart';

void main() {
  testWidgets('ScanInApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ScanInApp());

    expect(find.text('ចូលប្រើប្រាស់'), findsOneWidget);
    expect(find.text('ចូលប្រើ'), findsOneWidget);
  });
}
