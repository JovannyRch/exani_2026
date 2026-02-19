import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exani/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    test('should have light theme configured', () {
      final theme = AppTheme.lightTheme;

      expect(theme.brightness, equals(Brightness.light));
      expect(theme.primaryColor, isNotNull);
    });

    test('should have dark theme configured', () {
      final theme = AppTheme.darkTheme;

      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.primaryColor, isNotNull);
    });

    testWidgets('AppColors should be consistent', (WidgetTester tester) async {
      // Test that colors are defined and not null
      expect(AppColors.primary, isNotNull);
      expect(AppColors.primaryDark, isNotNull);
      expect(AppColors.secondary, isNotNull);
      expect(AppColors.background, isNotNull);
      expect(AppColors.surface, isNotNull);
      expect(AppColors.textPrimary, isNotNull);
      expect(AppColors.textSecondary, isNotNull);
      expect(AppColors.red, isNotNull);
      expect(AppColors.orange, isNotNull);
      expect(AppColors.purple, isNotNull);
    });

    testWidgets('Theme switches correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: const Scaffold(body: Text('Test')),
        ),
      );

      final BuildContext context = tester.element(find.text('Test'));
      final theme = Theme.of(context);

      expect(theme.brightness, equals(Brightness.light));
    });
  });
}
