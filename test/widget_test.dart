import 'package:flutter_test/flutter_test.dart';

import 'package:medcare/main.dart';

void main() {
  testWidgets('MedCare shows login page before authentication', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MedCareApp());

    expect(find.text('MedCare Login'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });
}
