// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:readyed/main.dart';

void main() {
  testWidgets('ReadyEd app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ReadyEdApp());

    // Verify that our app loads with the home screen.
    await tester.pumpAndSettle();
    expect(find.text('ReadyEd'), findsOneWidget);
    
    // Check for app content that should be present
    expect(find.text('Quick Access'), findsOneWidget);
    expect(find.text('Natural Disasters'), findsOneWidget);
  });
}
