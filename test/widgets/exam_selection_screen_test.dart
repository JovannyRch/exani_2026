import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exani/screens/exam_selection_screen.dart';
import 'package:exani/theme/app_theme.dart';

void main() {
  group('ExamSelectionScreen Widget', () {
    testWidgets('should display exam options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ExamSelectionScreen(onExamSelected: (examId) async {}),
        ),
      );

      // Should show title
      expect(find.text('¿Qué examen vas a presentar?'), findsOneWidget);

      // Should show both exam options
      expect(find.text('EXANI-II'), findsOneWidget);
      expect(find.text('EXANI-I'), findsOneWidget);
    });

    testWidgets('should trigger callback when exam selected', (
      WidgetTester tester,
    ) async {
      int? selectedExamId;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ExamSelectionScreen(
            onExamSelected: (examId) async {
              selectedExamId = examId;
            },
          ),
        ),
      );

      // Tap EXANI-II option
      await tester.tap(find.text('EXANI-II'));
      await tester.pumpAndSettle();

      expect(selectedExamId, equals(1));
    });

    testWidgets('should show exam descriptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ExamSelectionScreen(onExamSelected: (examId) async {}),
        ),
      );

      // Should show descriptive text
      expect(find.textContaining('Educación Superior'), findsOneWidget);
      expect(find.textContaining('Educación Media Superior'), findsOneWidget);
    });
  });
}
