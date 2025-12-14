// This is a basic Flutter widget test for the Biography app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:biography/main.dart';
import 'package:biography/services/update_service.dart';

void main() {
  testWidgets('Biography app loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(updateService: MockUpdateService()));

    // Verify that the login screen is displayed (default is not logged in).
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}

class MockUpdateService implements UpdateService {
  @override
  Future<void> checkForUpdate(BuildContext context) async {
    // Mock implementation - do nothing
  }
}
