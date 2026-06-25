import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Change this to your real app import
import 'package:qarazdare/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MyApp());

    // Wait for initial frames
    await tester.pumpAndSettle();

    // Example check: app should load without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
