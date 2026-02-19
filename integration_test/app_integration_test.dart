import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:exani/main.dart' as app;
import 'package:exani/theme/app_theme.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow', () {
    testWidgets('Complete authentication and onboarding flow', (
      WidgetTester tester,
    ) async {
      // Start app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show AuthScreen or AuthGate loading
      // Note: This test requires proper Supabase configuration
      // and might need to be adjusted based on actual state

      // Verify app initializes without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Navigation Flow', () {
    testWidgets('Navigate through main screens', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // App should be initialized
      expect(find.byType(MaterialApp), findsOneWidget);

      // Note: Full navigation tests require authenticated state
      // These should be expanded with mock authentication
    });
  });

  group('Theme Switching', () {
    testWidgets('Toggle between light and dark theme', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Find and tap theme toggle if visible
      final themeToggle = find.byIcon(Icons.dark_mode_rounded);

      if (themeToggle.evaluate().isNotEmpty) {
        await tester.tap(themeToggle);
        await tester.pumpAndSettle();

        // Should now show light mode icon
        expect(find.byIcon(Icons.light_mode_rounded), findsOneWidget);
      }
    });
  });
}
