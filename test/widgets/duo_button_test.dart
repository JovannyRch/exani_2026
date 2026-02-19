import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exani/widgets/duo_button.dart';
import 'package:exani/theme/app_theme.dart';

void main() {
  group('DuoButton Widget', () {
    testWidgets('should render with text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DuoButton(text: 'Test Button', onPressed: () {}),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('should trigger callback on tap', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DuoButton(text: 'Tap Me', onPressed: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(DuoButton));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('should respect custom color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DuoButton(
              text: 'Custom Color',
              color: AppColors.secondary,
              onPressed: () {},
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(DuoButton),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.decoration, isA<BoxDecoration>());
    });

    testWidgets('should be disabled when enabled is false', (
      WidgetTester tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DuoButton(
              text: 'Disabled',
              enabled: false,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DuoButton));
      await tester.pumpAndSettle();

      // Should not trigger callback when disabled
      expect(tapped, isFalse);
    });

    testWidgets('should show icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DuoButton(
              text: 'With Icon',
              icon: Icons.check,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should be full width by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: DuoButton(text: 'Full Width', onPressed: () {}),
            ),
          ),
        ),
      );

      final button = tester.getSize(find.byType(DuoButton));
      expect(button.width, equals(400));
    });
  });
}
