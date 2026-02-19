class Option {
  final int id;
  final String text;

  /// Imagen opcional para la opción (señales de tránsito, diagramas, fórmulas, etc.)
  /// Puede ser asset path ('assets/images/opcion_a.png') o URL remota
  final String? imagePath;

  Option({required this.id, required this.text, this.imagePath});

  /// True si esta opción tiene una imagen asociada
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;

  /// True si la imagen es una URL remota (http/https)
  bool get isRemoteImage =>
      hasImage &&
      (imagePath!.startsWith('http://') || imagePath!.startsWith('https://'));
}

/// Categories for practice mode — TODO: Customize for your app
enum QuestionCategory {
  senales('Categoría 1', '📖'),
  circulacion('Categoría 2', '📚'),
  multas('Categoría 3', '📝'),
  seguridad('Categoría 4', '🛡️'),
  vehiculo('Categoría 5', '📋'),
  prioridades('Categoría 6', '🔔');

  final String label;
  final String emoji;

  const QuestionCategory(this.label, this.emoji);
}

/// Nivel de dificultad de la pregunta
enum QuestionDifficulty {
  easy('Fácil'),
  medium('Media'),
  hard('Difícil');

  final String label;
  const QuestionDifficulty(this.label);
}

class Question {
  final int id;
  final String text;
  final List<Option> options;
  final int correctOptionId;
  final QuestionCategory category;

  /// ID de la skill a la que pertenece esta pregunta (para Supabase)
  final int? skillId;

  /// Imagen principal de la pregunta (señal de tránsito, diagrama, etc.)
  /// Puede ser asset path o URL remota
  final String? imagePath;

  /// Imágenes adicionales en el enunciado (para preguntas con múltiples figuras)
  /// Útil en EXANI: gráficas, tablas, diagramas complementarios
  final List<String> stemImages;

  /// Explicación en texto de por qué la respuesta es correcta
  final String? explanation;

  /// Imágenes que acompañan la explicación (diagramas explicativos, fórmulas, etc.)
  final List<String> explanationImages;

  /// Dificultad de la pregunta (para práctica adaptativa)
  final QuestionDifficulty difficulty;

  /// Tags libres para filtrado flexible (ej: ['velocidad', 'zona_urbana'])
  final List<String> tags;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionId,
    required this.category,
    this.skillId,
    this.imagePath,
    this.stemImages = const [],
    this.explanation,
    this.explanationImages = const [],
    this.difficulty = QuestionDifficulty.medium,
    this.tags = const [],
  });

  /// True si la pregunta tiene al menos una imagen (principal o adicionales)
  bool get hasImages =>
      (imagePath != null && imagePath!.isNotEmpty) || stemImages.isNotEmpty;

  /// True si la explicación tiene imágenes asociadas
  bool get hasExplanationImages => explanationImages.isNotEmpty;

  /// Todas las imágenes del enunciado (principal + adicionales) en orden
  List<String> get allStemImages => [
    if (imagePath != null && imagePath!.isNotEmpty) imagePath!,
    ...stemImages,
  ];

  /// Devuelve las opciones en desorden, incluyendo siempre la correcta
  List<Option> getShuffledOptions({int maxOptions = 4}) {
    // Si pedimos todas o más opciones de las disponibles, solo hacemos shuffle
    if (maxOptions >= options.length) {
      List<Option> shuffled = List.from(options);
      shuffled.shuffle();
      return shuffled;
    }

    // Encontrar la opción correcta
    Option correct = options.firstWhere((o) => o.id == correctOptionId);

    // Crear lista sin la opción correcta
    List<Option> others =
        options.where((o) => o.id != correctOptionId).toList();

    // Hacer shuffle de las otras opciones
    others.shuffle();

    // Tomar maxOptions - 1 de las otras opciones
    List<Option> selected = others.take(maxOptions - 1).toList();

    // Agregar la opción correcta
    selected.add(correct);

    // Hacer shuffle final para que la correcta no siempre esté al final
    selected.shuffle();

    return selected;
  }

  /// Factory constructor para crear Question desde datos de Supabase
  factory Question.fromSupabase(Map<String, dynamic> json) {
    // Parse options_json from Supabase
    final optionsJson = json['options_json'] as List<dynamic>;
    final correctKey = json['correct_key'] as String;

    // Convert options with mapping key -> id (a=1, b=2, c=3, d=4)
    final options = <Option>[];
    int correctOptionId = 1;

    for (int i = 0; i < optionsJson.length; i++) {
      final opt = optionsJson[i] as Map<String, dynamic>;
      final key = opt['key'] as String;
      final id = i + 1; // Use 1-based indexing

      options.add(
        Option(
          id: id,
          text: opt['text'] as String,
          imagePath: opt['image'] as String?,
        ),
      );

      // Track which id corresponds to the correct key
      if (key == correctKey) {
        correctOptionId = id;
      }
    }

    // Parse difficulty
    final difficultyStr = json['difficulty'] as String?;
    final difficulty =
        difficultyStr != null
            ? QuestionDifficulty.values.firstWhere(
              (d) => d.name == difficultyStr,
              orElse: () => QuestionDifficulty.medium,
            )
            : QuestionDifficulty.medium;

    // Parse tags
    final tagsJson = json['tags_json'] as List<dynamic>? ?? [];
    final tags = tagsJson.map((t) => t.toString()).toList();

    // Parse images
    final stemImagesJson = json['stem_images_json'] as List<dynamic>? ?? [];
    final stemImages = stemImagesJson.map((img) => img.toString()).toList();

    final explanationImagesJson =
        json['explanation_images_json'] as List<dynamic>? ?? [];
    final explanationImages =
        explanationImagesJson.map((img) => img.toString()).toList();

    // Use a default category or derive from tags
    // For EXANI, we don't use categories, so default to first category
    final category = QuestionCategory.senales;

    return Question(
      id: json['id'] as int,
      text: json['stem'] as String,
      options: options,
      correctOptionId: correctOptionId,
      category: category,
      skillId: json['skill_id'] as int?,
      imagePath: json['stem_image'] as String?,
      stemImages: stemImages,
      explanation: json['explanation'] as String?,
      explanationImages: explanationImages,
      difficulty: difficulty,
      tags: tags,
    );
  }
}
