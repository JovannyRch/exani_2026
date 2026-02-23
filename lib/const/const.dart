const String PDF_URL = "https://example.com/your_guide.pdf";

const String PLAYSTORE_APP_ID =
    "https://play.google.com/store/apps/details?id=com.jovasoft.exani";

// ─── Exam Configuration ─────────────────────────────────────────────────────
// Porcentaje general de aprobación para todos los exámenes
const double EXAM_PASSING_PERCENTAGE = 60.0;

// NOTA: La duración y cantidad de preguntas se obtienen dinámicamente
// desde la tabla exam_configs en Supabase según el tipo de examen:
// - EXANI-II: 168 preguntas, 270 minutos
// - EXANI-I: 160 preguntas, 270 minutos
