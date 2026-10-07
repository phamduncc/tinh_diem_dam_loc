import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinh_diem_sam_loc/main.dart';

void main() {
  testWidgets('App smoke test - starts HomeScreen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const SamDiemApp());
    await tester.pumpAndSettle();

    expect(find.text('+ BÀN MỚI'), findsOneWidget);
  });
}
