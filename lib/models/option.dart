import 'dart:math';

class Option {
  final int id;
  final String text;

  Option({required this.id, required this.text});
}

class Question {
  final int id;
  final String text;
  final List<Option> options;
  final int correctOptionId;
  final String? imagePath; // Para preguntas con imágenes opcionales

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionId,
    this.imagePath,
  });

  /// Devuelve las opciones en desorden, incluyendo siempre la correcta
  List<Option> getShuffledOptions({int maxOptions = 4}) {
    List<Option> shuffled = List.from(options);

    // Asegurar que la opción correcta esté incluida
    Option correct = shuffled.firstWhere((o) => o.id == correctOptionId);

    // Si hay más opciones de las necesarias, reducimos a maxOptions
    if (shuffled.length > maxOptions) {
      shuffled.shuffle();
      if (!shuffled.contains(correct)) {
        shuffled[0] = correct;
      }
      shuffled = shuffled.take(maxOptions).toList();
    }

    shuffled.shuffle();
    return shuffled;
  }
}
