import 'package:flutter_test/flutter_test.dart';
import 'package:exani/models/option.dart';

void main() {
  group('Question Model', () {
    test('should create question with required fields', () {
      final question = Question(
        id: 1,
        text: 'What is 2 + 2?',
        options: [
          Option(id: 1, text: '3'),
          Option(id: 2, text: '4'),
          Option(id: 3, text: '5'),
        ],
        correctOptionId: 2,
        category: QuestionCategory.general,
      );

      expect(question.id, equals(1));
      expect(question.text, equals('What is 2 + 2?'));
      expect(question.options.length, equals(3));
      expect(question.correctOptionId, equals(2));
      expect(question.category, equals(QuestionCategory.general));
    });

    test('should create question from Supabase data', () {
      final supabaseData = {
        'id': 1,
        'question_text': 'Sample question',
        'correct_option': 2,
        'skill_id': 5,
        'options': [
          {'option_id': 1, 'option_text': 'Option A'},
          {'option_id': 2, 'option_text': 'Option B'},
          {'option_id': 3, 'option_text': 'Option C'},
        ],
      };

      final question = Question.fromSupabase(supabaseData);

      expect(question.id, equals(1));
      expect(question.text, equals('Sample question'));
      expect(question.correctOptionId, equals(2));
      expect(question.skillId, equals(5));
      expect(question.options.length, equals(3));
      expect(question.options[0].text, equals('Option A'));
    });

    test('should handle question without skillId', () {
      final supabaseData = {
        'id': 1,
        'question_text': 'Question without skill',
        'correct_option': 1,
        'options': [
          {'option_id': 1, 'option_text': 'Correct'},
          {'option_id': 2, 'option_text': 'Wrong'},
        ],
      };

      final question = Question.fromSupabase(supabaseData);

      expect(question.skillId, isNull);
    });

    test('should shuffle options maintaining correct answer', () {
      final question = Question(
        id: 1,
        text: 'Test question',
        options: [
          Option(id: 1, text: 'A'),
          Option(id: 2, text: 'B'),
          Option(id: 3, text: 'C'),
          Option(id: 4, text: 'D'),
        ],
        correctOptionId: 2,
        category: QuestionCategory.general,
      );

      final shuffled = question.getShuffledOptions();

      // Should have all options
      expect(shuffled.length, equals(4));

      // Should contain the correct option
      expect(shuffled.any((opt) => opt.id == question.correctOptionId), isTrue);

      // IDs should be unique
      final ids = shuffled.map((o) => o.id).toSet();
      expect(ids.length, equals(shuffled.length));
    });

    test('should limit shuffled options when maxOptions specified', () {
      final question = Question(
        id: 1,
        text: 'Test question',
        options: [
          Option(id: 1, text: 'A'),
          Option(id: 2, text: 'B'),
          Option(id: 3, text: 'C'),
          Option(id: 4, text: 'D'),
        ],
        category: QuestionCategory.general,
        correctOptionId: 2,
      );

      final shuffled = question.getShuffledOptions(maxOptions: 3);

      expect(shuffled.length, equals(3));
      // Should still contain correct option
      expect(shuffled.any((opt) => opt.id == question.correctOptionId), isTrue);
    });

    test('should handle optional fields', () {
      final question = Question(
        id: 1,
        text: 'Question with extras',
        options: [Option(id: 1, text: 'A')],
        category: QuestionCategory.general,
        correctOptionId: 1,
        imagePath: 'assets/image.png',
        explanation: 'This is the explanation',
        difficulty: QuestionDifficulty.medium,
        tags: ['math', 'algebra'],
      );

      expect(question.imagePath, equals('assets/image.png'));
      expect(question.explanation, equals('This is the explanation'));
      expect(question.difficulty, equals(QuestionDifficulty.medium));
      expect(question.tags, equals(['math', 'algebra']));
    });
  });

  group('Option Model', () {
    test('should create option with required fields', () {
      final option = Option(id: 1, text: 'Option A');

      expect(option.id, equals(1));
      expect(option.text, equals('Option A'));
    });

    test('should support option with image', () {
      final option = Option(
        id: 1,
        text: 'Option A',
        imagePath: 'assets/option.png',
      );

      expect(option.imagePath, equals('assets/option.png'));
    });
  });

  group('QuestionDifficulty', () {
    test('should have correct difficulty levels', () {
      expect(QuestionDifficulty.easy, isNotNull);
      expect(QuestionDifficulty.medium, isNotNull);
      expect(QuestionDifficulty.hard, isNotNull);
    });
  });
}
