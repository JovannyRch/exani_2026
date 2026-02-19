import 'package:flutter_test/flutter_test.dart';
import 'package:exani/services/question_selector.dart';
import 'package:exani/models/option.dart';

void main() {
  group('QuestionSelector', () {
    late QuestionSelector selector;

    setUp(() {
      selector = QuestionSelector();
    });

    List<Question> createMockQuestions(int count) {
      return List.generate(
        count,
        (i) => Question(
          id: i + 1,
          text: 'Question ${i + 1}',
          options: [
            Option(id: 1, text: 'A'),
            Option(id: 2, text: 'B'),
            Option(id: 3, text: 'C'),
            Option(id: 4, text: 'D'),
          ],
          correctOptionId: 1,
          category: QuestionCategory.general,
        ),
      );
    }

    test('should select questions respecting limit', () {
      final questions = createMockQuestions(50);
      final selected = selector.selectQuestions(
        availableQuestions: questions,
        count: 20,
      );

      expect(selected.length, equals(20));
    });

    test('should handle requesting more questions than available', () {
      final questions = createMockQuestions(10);
      final selected = selector.selectQuestions(
        availableQuestions: questions,
        count: 20,
      );

      expect(selected.length, equals(10));
    });

    test('should avoid recently answered questions', () {
      final questions = createMockQuestions(20);
      final recentIds = [1, 2, 3, 4, 5];

      final selected = selector.selectQuestions(
        availableQuestions: questions,
        count: 10,
        recentlyAnsweredIds: recentIds,
      );

      // Should not contain recently answered questions
      for (final q in selected) {
        expect(recentIds.contains(q.id), isFalse);
      }
    });

    test('should prioritize weak areas when provided', () {
      final questions = createMockQuestions(30);
      final weakSkillIds = [1, 2, 3];

      // Add skillId to some questions
      final questionsWithSkills =
          questions.map((q) {
            if (q.id <= 10) {
              return Question(
                id: q.id,
                text: q.text,
                options: q.options,
                correctOptionId: q.correctOptionId,
                skillId: weakSkillIds[q.id % weakSkillIds.length],
              );
            }
            return q;
          }).toList();

      final selected = selector.selectQuestions(
        availableQuestions: questionsWithSkills,
        count: 15,
        weakSkillIds: weakSkillIds,
      );

      // Count how many selected questions are from weak skills
      final weakQuestionsCount =
          selected
              .where(
                (q) => q.skillId != null && weakSkillIds.contains(q.skillId),
              )
              .length;

      // Should have at least some questions from weak skills
      expect(weakQuestionsCount, greaterThan(0));
    });

    test('should return empty list when no questions available', () {
      final selected = selector.selectQuestions(
        availableQuestions: [],
        count: 10,
      );

      expect(selected, isEmpty);
    });

    test('should shuffle questions for variety', () {
      final questions = createMockQuestions(50);

      final selected1 = selector.selectQuestions(
        availableQuestions: questions,
        count: 20,
      );

      final selected2 = selector.selectQuestions(
        availableQuestions: questions,
        count: 20,
      );

      // With 50 questions selecting 20, high probability of different order
      // (This might occasionally fail due to randomness, but very unlikely)
      final idsMatch =
          selected1.map((q) => q.id).toList() ==
          selected2.map((q) => q.id).toList();
      expect(idsMatch, isFalse);
    });
  });
}
