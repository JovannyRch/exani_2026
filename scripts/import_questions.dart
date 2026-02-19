// ═══════════════════════════════════════════════════════════════════════════════
// EXANI Prep — Question Import Script (Dart)
// Ejecutar: dart run scripts/import_questions.dart
// ═══════════════════════════════════════════════════════════════════════════════

import 'package:supabase_flutter/supabase_flutter.dart';

// CONFIGURACIÓN - Reemplaza con tus credenciales de Supabase
const supabaseUrl = 'YOUR_SUPABASE_URL';
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

void main() async {
  // Inicializar Supabase
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  final supabase = Supabase.instance.client;

  print('🚀 Iniciando importación de preguntas...\n');

  try {
    // EJEMPLO 1: Insertar una sola pregunta
    await insertSingleQuestion(supabase);

    // EJEMPLO 2: Insertar preguntas en lote
    await insertBatchQuestions(supabase);

    print('\n✅ Importación completada exitosamente!');
  } catch (e) {
    print('\n❌ Error durante la importación: $e');
  }
}

// ─── EJEMPLO 1: Insertar una sola pregunta ────────────────────────────────────

Future<void> insertSingleQuestion(SupabaseClient supabase) async {
  print('📝 Insertando pregunta individual...');

  final question = {
    'skill_id': 1, // Comprensión lectora - Idea principal
    'set_id': 1, // EXANI-II v1.0
    'stem':
        'Lee el siguiente texto: "El desarrollo sostenible busca equilibrar el crecimiento económico con la protección ambiental." ¿Cuál es la idea principal?',
    'stem_image': null,
    'stem_images_json': [],
    'options_json': [
      {
        'key': 'a',
        'text': 'El crecimiento económico es importante',
        'image': null,
      },
      {
        'key': 'b',
        'text': 'El desarrollo sostenible equilibra economía y ambiente',
        'image': null,
      },
      {
        'key': 'c',
        'text': 'La protección ambiental cuesta dinero',
        'image': null,
      },
      {'key': 'd', 'text': 'El desarrollo es imposible', 'image': null},
    ],
    'correct_key': 'b',
    'explanation':
        'La idea principal menciona explícitamente el equilibrio entre dos aspectos: crecimiento económico y protección ambiental.',
    'explanation_images_json': [],
    'difficulty': 'medium',
    'tags_json': [
      'comprension_lectora',
      'idea_principal',
      'desarrollo_sostenible',
    ],
    'source': 'Banco de preguntas EXANI-II',
    'is_active': true,
  };

  final response = await supabase.from('questions').insert(question).select();

  print('   ✓ Pregunta insertada con ID: ${response.first['id']}');
}

// ─── EJEMPLO 2: Insertar preguntas en lote ───────────────────────────────────

Future<void> insertBatchQuestions(SupabaseClient supabase) async {
  print('\n📦 Insertando lote de preguntas...');

  final questions = [
    // Pregunta 1: Redacción - Ortografía
    {
      'skill_id': 4,
      'set_id': 1,
      'stem': '¿Qué palabra requiere acento ortográfico?',
      'options_json': [
        {'key': 'a', 'text': 'Carcel', 'image': null},
        {'key': 'b', 'text': 'Pared', 'image': null},
        {'key': 'c', 'text': 'Lapiz', 'image': null},
        {'key': 'd', 'text': 'Ciudad', 'image': null},
      ],
      'correct_key': 'a',
      'explanation':
          'La palabra correcta es "cárcel" (palabra grave terminada en consonante diferente de n o s lleva tilde). "Lápiz" también la necesita (opción c), pero cárcel es grave y requiere tilde.',
      'difficulty': 'medium',
      'tags_json': ['ortografia', 'acentuacion'],
      'is_active': true,
    },

    // Pregunta 2: Matemáticas - Aritmética
    {
      'skill_id': 7,
      'set_id': 1,
      'stem':
          'Si compras 3 cuadernos a \$45 cada uno y pagas con un billete de \$200, ¿cuánto te dan de cambio?',
      'options_json': [
        {'key': 'a', 'text': '\$55', 'image': null},
        {'key': 'b', 'text': '\$65', 'image': null},
        {'key': 'c', 'text': '\$135', 'image': null},
        {'key': 'd', 'text': '\$155', 'image': null},
      ],
      'correct_key': 'a',
      'explanation': 'Total = 3 × \$45 = \$135. Cambio = \$200 - \$135 = \$55',
      'difficulty': 'easy',
      'tags_json': ['aritmetica', 'operaciones_basicas'],
      'is_active': true,
    },

    // Pregunta 3: Álgebra
    {
      'skill_id': 8,
      'set_id': 1,
      'stem': 'Resuelve la ecuación: 3(x - 2) = 15',
      'options_json': [
        {'key': 'a', 'text': 'x = 5', 'image': null},
        {'key': 'b', 'text': 'x = 7', 'image': null},
        {'key': 'c', 'text': 'x = 9', 'image': null},
        {'key': 'd', 'text': 'x = 3', 'image': null},
      ],
      'correct_key': 'b',
      'explanation': '3(x - 2) = 15 → x - 2 = 5 → x = 7',
      'difficulty': 'medium',
      'tags_json': ['algebra', 'ecuaciones_lineales'],
      'is_active': true,
    },

    // Pregunta 4: Geometría
    {
      'skill_id': 9,
      'set_id': 1,
      'stem': 'Un cuadrado tiene un perímetro de 36 cm. ¿Cuál es su área?',
      'options_json': [
        {'key': 'a', 'text': '36 cm²', 'image': null},
        {'key': 'b', 'text': '81 cm²', 'image': null},
        {'key': 'c', 'text': '144 cm²', 'image': null},
        {'key': 'd', 'text': '9 cm²', 'image': null},
      ],
      'correct_key': 'b',
      'explanation':
          'Perímetro = 4 × lado, entonces lado = 36/4 = 9 cm. Área = 9² = 81 cm²',
      'difficulty': 'medium',
      'tags_json': ['geometria', 'areas', 'cuadrados'],
      'is_active': true,
    },

    // Pregunta 5: Física - Mecánica
    {
      'skill_id': 10,
      'set_id': 1,
      'stem':
          'Un objeto se mueve con velocidad constante de 20 m/s. ¿Qué distancia recorre en 5 segundos?',
      'options_json': [
        {'key': 'a', 'text': '4 m', 'image': null},
        {'key': 'b', 'text': '25 m', 'image': null},
        {'key': 'c', 'text': '100 m', 'image': null},
        {'key': 'd', 'text': '15 m', 'image': null},
      ],
      'correct_key': 'c',
      'explanation': 'Distancia = velocidad × tiempo = 20 m/s × 5 s = 100 m',
      'difficulty': 'easy',
      'tags_json': ['fisica', 'cinematica', 'velocidad'],
      'is_active': true,
    },
  ];

  // Insertar todas las preguntas en un solo request
  final response = await supabase.from('questions').insert(questions).select();

  print('   ✓ ${response.length} preguntas insertadas correctamente');

  // Mostrar IDs de las preguntas insertadas
  for (var question in response) {
    print('     → ID: ${question['id']} - Skill: ${question['skill_id']}');
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CÓMO USAR ESTE SCRIPT:
// ═══════════════════════════════════════════════════════════════════════════════
//
// 1. Instala dependencias:
//    flutter pub get
//
// 2. Configura las credenciales de Supabase (líneas 7-8):
//    - Obtén la URL desde: Supabase Dashboard → Settings → API
//    - Obtén la anon key desde el mismo lugar
//
// 3. Ejecuta el script:
//    dart run scripts/import_questions.dart
//
// 4. Para importar preguntas masivamente:
//    - Modifica la lista 'questions' en insertBatchQuestions()
//    - Puedes insertar hasta 1000 preguntas por lote
//    - Para más de 1000, divide en múltiples lotes
//
// ═══════════════════════════════════════════════════════════════════════════════
// DISTRIBUCIÓN RECOMENDADA PARA 168 PREGUNTAS (SIMULACIÓN EXANI-II):
// ═══════════════════════════════════════════════════════════════════════════════
//
// Comprensión lectora (section_id = 1):    30 preguntas
// Redacción indirecta (section_id = 2):    30 preguntas
// Pensamiento matemático (section_id = 3): 30 preguntas
// Módulo 1 (ej: Física, section_id = 4):   24 preguntas
// Módulo 2 (ej: Química, section_id = 5):  24 preguntas
// Inglés diagnóstico (section_id = 8):     30 preguntas
//                                          ───────────────
//                                          TOTAL: 168
//
// ═══════════════════════════════════════════════════════════════════════════════
