import 'package:flutter_test/flutter_test.dart';
import 'package:scan_in_admin/core/app_routes.dart';
import 'package:scan_in_admin/main.dart';

void main() {
  testWidgets('ScanInAdminApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ScanInAdminApp(initialRoute: AppRoutes.login));
    expect(find.byType(ScanInAdminApp), findsOneWidget);
  });
}
