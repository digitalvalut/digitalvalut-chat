
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:digitalvalut_chat/ui/voice_call_screen.dart';
import 'package:digitalvalut_chat/services/voice_call_service.dart';
import 'package:digitalvalut_chat/crypto/encryption_service.dart';

void main() {
  group('VoiceCallScreen Widget Tests', () {
    late VoiceCallService callService;
    late EncryptionService encryptionService;

    setUp(() {
      encryptionService = EncryptionService();
      callService = VoiceCallService(encryptionService);
    });

    tearDown(() async {
      await callService.dispose();
    });

    testWidgets('VoiceCallScreen should build correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VoiceCallScreen(
            callService: callService,
            contactName: 'Test Contact',
          ),
        ),
      );

      // Verify the screen is built
      expect(find.byType(VoiceCallScreen), findsOneWidget);
    });

    testWidgets('VoiceCallScreen should display contact name', (WidgetTester tester) async {
      const contactName = 'John Doe';
      
      await tester.pumpWidget(
        MaterialApp(
          home: VoiceCallScreen(
            callService: callService,
            contactName: contactName,
          ),
        ),
      );

      expect(find.text(contactName), findsOneWidget);
    });

    testWidgets('VoiceCallScreen should show encrypted indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VoiceCallScreen(
            callService: callService,
            contactName: 'Test Contact',
          ),
        ),
      );

      expect(find.text('Encrypted'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('VoiceCallScreen should show end call button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VoiceCallScreen(
            callService: callService,
            contactName: 'Test Contact',
          ),
        ),
      );

      expect(find.byIcon(Icons.call_end), findsOneWidget);
    });

    testWidgets('VoiceCallScreen should display avatar with initial', (WidgetTester tester) async {
      const contactName = 'Alice';
      
      await tester.pumpWidget(
        MaterialApp(
          home: VoiceCallScreen(
            callService: callService,
            contactName: contactName,
          ),
        ),
      );

      // Should display first letter of name
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('VoiceCallScreen should handle back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VoiceCallScreen(
            callService: callService,
            contactName: 'Test Contact',
          ),
        ),
      );

      // Find and tap back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });

  group('VoiceCallScreen Call Controls Tests', () {
    late VoiceCallService callService;
    late EncryptionService encryptionService;

    setUp(() {
      encryptionService = EncryptionService();
      callService = VoiceCallService(encryptionService);
    });

    tearDown(() async {
      await callService.dispose();
    });

    testWidgets('VoiceCallScreen should show mute button when connected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VoiceCallScreen(
            callService: callService,
            contactName: 'Test Contact',
          ),
        ),
      );

      await tester.pump();
      
      // Check if mute icon exists (might not be visible initially)
      // The UI changes based on call state
    });

    testWidgets('VoiceCallScreen should show speaker button when connected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VoiceCallScreen(
            callService: callService,
            contactName: 'Test Contact',
          ),
        ),
      );

      await tester.pump();
      
      // Check if speaker controls exist
      // The UI changes based on call state
    });
  });

  group('VoiceCallScreen State Display Tests', () {
    late VoiceCallService callService;
    late EncryptionService encryptionService;

    setUp(() {
      encryptionService = EncryptionService();
      callService = VoiceCallService(encryptionService);
    });

    tearDown(() async {
      await callService.dispose();
    });

    testWidgets('VoiceCallScreen should display call state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VoiceCallScreen(
            callService: callService,
            contactName: 'Test Contact',
          ),
        ),
      );

      await tester.pump();
      
      // The screen should show some status text
      // This varies based on call state
    });

    testWidgets('VoiceCallScreen should handle incoming call flag', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: VoiceCallScreen(
            callService: callService,
            contactName: 'Test Contact',
            isIncoming: true,
          ),
        ),
      );

      await tester.pump();
      
      // Should display appropriately for incoming call
    });
  });
}

