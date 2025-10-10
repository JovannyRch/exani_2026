import 'dart:math';

import 'package:examen_vial_edomex_app_2025/models/option.dart';

class Question {
  final int id;
  final String text;
  final List<Option> options;
  final int correctAnswerId;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerId,
  });

  String get formattedText => text.replaceAll('[br]', '\n');
  String get formattedAnswer => options
      .firstWhere((o) => o.id == correctAnswerId)
      .text
      .replaceAll('[br]', '\n');
  String get correctAnswer => options
      .firstWhere((o) => o.id == correctAnswerId)
      .text
      .replaceAll('[br]', '\n');

  List<Option> get shuffledOptions {
    final random = Random();
    final shuffled = List<Option>.from(options);
    shuffled.shuffle(random);
    return shuffled;
  }
}
