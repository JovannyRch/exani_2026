import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exani/widgets/app_loader.dart';
import 'package:exani/theme/app_theme.dart';

void main() {
  group('AppLoader Widget', () {
    testWidgets('should render bouncing dots loader', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppLoader())),
      );

      // Should have 3 animated containers (dots)
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('should show custom message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppLoader(message: 'Loading data...')),
        ),
      );

      expect(find.text('Loading data...'), findsOneWidget);
    });

    testWidgets('AppLoading.show should display dialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      AppLoading.show(context, message: 'Please wait...');
                    },
                    child: const Text('Show Loading'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Tap button to show loading
      await tester.tap(find.text('Show Loading'));
      await tester.pumpAndSettle();

      expect(find.text('Please wait...'), findsOneWidget);
      expect(find.byType(AppLoader), findsOneWidget);
    });

    testWidgets('AppPulseLoader should animate', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppPulseLoader())),
      );

      expect(find.byType(AnimatedBuilder), findsOneWidget);
    });

    testWidgets('AppSpinnerLoader should rotate', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppSpinnerLoader())),
      );

      expect(find.byType(AnimatedBuilder), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
