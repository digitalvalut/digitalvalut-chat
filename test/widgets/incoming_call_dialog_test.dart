
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digitalvalut_chat/widgets/incoming_call_dialog.dart';

void main() {
  group('IncomingCallDialog Widget Tests', () {
    testWidgets('Dialog should display caller name', (WidgetTester tester) async {
      const callerName = 'John Doe';
      bool accepted = false;
      bool rejected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncomingCallDialog(
              callerName: callerName,
              onAccept: () => accepted = true,
              onReject: () => rejected = true,
            ),
          ),
        ),
      );

      expect(find.text(callerName), findsOneWidget);
    });

    testWidgets('Dialog should show accept and reject buttons', (WidgetTester tester) async {
      bool accepted = false;
      bool rejected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncomingCallDialog(
              callerName: 'Test User',
              onAccept: () => accepted = true,
              onReject: () => rejected = true,
            ),
          ),
        ),
      );

      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
    });

    testWidgets('Dialog should show encrypted indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncomingCallDialog(
              callerName: 'Test User',
              onAccept: () {},
              onReject: () {},
            ),
          ),
        ),
      );

      expect(find.text('Encrypted'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('Dialog should display avatar with initial', (WidgetTester tester) async {
      const callerName = 'Alice';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncomingCallDialog(
              callerName: callerName,
              onAccept: () {},
              onReject: () {},
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('Accept button should trigger callback', (WidgetTester tester) async {
      bool accepted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncomingCallDialog(
              callerName: 'Test User',
              onAccept: () => accepted = true,
              onReject: () {},
            ),
          ),
        ),
      );

      // Find the accept button by icon
      final acceptButton = find.byIcon(Icons.call);
      expect(acceptButton, findsOneWidget);

      // Tap the accept button
      await tester.tap(acceptButton);
      await tester.pump();

      expect(accepted, true);
    });

    testWidgets('Reject button should trigger callback', (WidgetTester tester) async {
      bool rejected = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncomingCallDialog(
              callerName: 'Test User',
              onAccept: () {},
              onReject: () => rejected = true,
            ),
          ),
        ),
      );

      // Find the reject button by icon
      final rejectButton = find.byIcon(Icons.call_end);
      expect(rejectButton, findsOneWidget);

      // Tap the reject button
      await tester.tap(rejectButton);
      await tester.pump();

      expect(rejected, true);
    });

    testWidgets('Dialog should show voice call indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncomingCallDialog(
              callerName: 'Test User',
              onAccept: () {},
              onReject: () {},
            ),
          ),
        ),
      );

      expect(find.text('Voice Call'), findsOneWidget);
      expect(find.byIcon(Icons.call), findsOneWidget);
    });
  });
}

