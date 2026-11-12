
import 'package:flutter_test/flutter_test.dart';
import 'package:loboko/app/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('LOBOKO app starts correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const LobokoApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('LOBOKO'), findsOneWidget);
  });
}
