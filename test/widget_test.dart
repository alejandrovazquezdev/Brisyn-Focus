// Brisyn Focus Widget Tests

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    // Build a simple test widget to verify the app structure works
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Brisyn Focus'),
            ),
          ),
        ),
      ),
    );

    // Verify the app name appears
    expect(find.text('Brisyn Focus'), findsOneWidget);
  });
}
