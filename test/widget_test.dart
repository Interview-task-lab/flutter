import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_login_app/main.dart';

void main() {
  testWidgets('Login screen loads with City dropdown, Premium toggle, and login flow', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const MyApp());

    // Verify initial components
    expect(find.byKey(const Key('login-scaffold')), findsOneWidget);
    expect(find.byKey(const Key('city-dropdown')), findsOneWidget);
    expect(find.byKey(const Key('premium-toggle')), findsOneWidget);

    // Scroll down to reveal the login button
    final scrollable = find.byType(SingleChildScrollView);
    await tester.drag(scrollable, const Offset(0, -600));
    await tester.pumpAndSettle();

    await tester.drag(scrollable, const Offset(0, -600));
    await tester.pumpAndSettle();

    // Verify login button is present and click it
    expect(find.byKey(const Key('login-button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('login-button')));
    await tester.pumpAndSettle();

    // Verify navigating to home screen
    expect(find.byKey(const Key('home-scaffold')), findsOneWidget);
    expect(find.byKey(const Key('welcome-text')), findsOneWidget);
  });
}
