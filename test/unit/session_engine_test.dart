import 'package:flutter_test/flutter_test.dart';
import 'package:exani/models/session.dart';

void main() {
  group('SessionConfig', () {
    test('should create diagnostic config', () {
      final config = SessionConfig.diagnostic(examId: 1, numQuestions: 25);

      expect(config.mode, equals(SessionMode.diagnostic));
      expect(config.numQuestions, equals(25));
      expect(config.hasTimeLimit, isFalse);
      expect(config.timeLimitMinutes, isNull);
    });

    test('should create practice config with section filter', () {
      final config = SessionConfig.practice(
        examId: 1,
        sectionId: 5,
        numQuestions: 20,
      );

      expect(config.mode, equals(SessionMode.practice));
      expect(config.sectionId, equals(5));
      expect(config.numQuestions, equals(20));
      expect(config.hasTimeLimit, isFalse);
    });

    test('should create practice config with area filter', () {
      final config = SessionConfig.practice(
        examId: 1,
        areaId: 10,
        numQuestions: 15,
      );

      expect(config.mode, equals(SessionMode.practice));
      expect(config.areaId, equals(10));
      expect(config.numQuestions, equals(15));
    });

    test('should create practice config with skill filter', () {
      final config = SessionConfig.practice(
        examId: 1,
        skillId: 25,
        numQuestions: 10,
      );

      expect(config.mode, equals(SessionMode.practice));
      expect(config.skillId, equals(25));
      expect(config.numQuestions, equals(10));
    });

    test('should create simulation config with time limit', () {
      final config = SessionConfig.simulation(
        examId: 1,
        numQuestions: 168,
        timeLimitMinutes: 270,
      );

      expect(config.mode, equals(SessionMode.simulation));
      expect(config.numQuestions, equals(168));
      expect(config.hasTimeLimit, isTrue);
      expect(config.timeLimitMinutes, equals(270));
      expect(config.isSimulation, isTrue);
    });

    test('SessionMode should have correct labels', () {
      expect(SessionMode.diagnostic.label, equals('Diagnóstico'));
      expect(SessionMode.practice.label, equals('Práctica'));
      expect(SessionMode.simulation.label, equals('Simulacro'));
    });

    test('should identify practice mode correctly', () {
      final diagnostic = SessionConfig.diagnostic(examId: 1, numQuestions: 25);
      final practice = SessionConfig.practice(examId: 1, numQuestions: 20);
      final simulation = SessionConfig.simulation(
        examId: 1,
        numQuestions: 168,
        timeLimitMinutes: 270,
      );

      expect(diagnostic.isPractice, isFalse);
      expect(practice.isPractice, isTrue);
      expect(simulation.isPractice, isFalse);
    });

    test('should identify diagnostic mode correctly', () {
      final diagnostic = SessionConfig.diagnostic(examId: 1, numQuestions: 25);
      final practice = SessionConfig.practice(examId: 1, numQuestions: 20);

      expect(diagnostic.isDiagnostic, isTrue);
      expect(practice.isDiagnostic, isFalse);
    });
  });
}
