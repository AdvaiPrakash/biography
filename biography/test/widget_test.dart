// This is a basic Flutter widget test for the Biography app.

import 'package:flutter_test/flutter_test.dart';

import 'package:biography/main.dart';

void main() {
  testWidgets('Biography app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BiographyApp());

    // Verify that the app title is displayed.
    expect(find.text('Biography'), findsOneWidget);

    // Verify that the profile name is displayed.
    expect(find.text('John Doe'), findsOneWidget);

    // Verify that the job title is displayed.
    expect(find.text('Software Developer'), findsOneWidget);
  });
}
