// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:project_watch_tower/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProjectWatchtowerApp());

    // Verify that the app loads (this is a basic smoke test)
    await tester.pumpAndSettle();
    
    // The test passes if no exceptions are thrown during app initialization
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
