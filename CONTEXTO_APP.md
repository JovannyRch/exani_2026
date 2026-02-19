# Contexto de la App — EXANI 2025

## 📋 Descripción General

App de Flutter orientada a usuarios que necesitan aprobar el **examen EXANI-II** (Examen Nacional de Ingreso a la Educación Superior). Permite diagnóstico de conocimientos, práctica por habilidades y simulacros con condiciones reales del examen.

- **Plataforma:** Android + iOS
- **Backend:** Supabase (PostgreSQL + Auth + RLS)
- **SDK:** Flutter ≥ 3.7.0
- **Monetización:** Google AdMob + In-App Purchases (Pro)

---

## 🏗️ Arquitectura Actual

```
lib/
├── main.dart                          # Entry point, inicializa servicios
├── const/const.dart                   # Constantes globales
├── models/
│   ├── option.dart                    # Question y Option (con skillId)
│   ├── exam_result.dart               # Resultado de examen
│   ├── question_stat.dart             # Estadísticas por pregunta
│   ├── session.dart                   # SessionConfig y SessionMode
│   └── leaderboard.dart               # Leaderboard entries
├── services/
│   ├── supabase_service.dart          # Cliente Supabase + helpers
│   ├── supabase_session_repository.dart # Implementación repo Supabase
│   ├── session_repository.dart        # Interface para session data
│   ├── session_engine.dart            # Motor de sesiones reutilizable
│   ├── question_selector.dart         # Selección inteligente
│   ├── cache_service.dart             # Caché TTL (in-memory + SharedPreferences)
│   ├── leaderboard_service.dart       # Tabla de posiciones
│   ├── theme_service.dart             # Persistencia tema
│   ├── admob_service.dart             # Ads
│   ├── sound_service.dart             # Efectos sonido
│   ├── notification_service.dart      # Recordatorios
│   ├── purchase_service.dart          # IAP Pro
│   └── database_service.dart          # SQLite local
├── screens/
│   ├── auth_gate.dart                 # Control autenticación
│   ├── auth_screen.dart               # Login/Registro Supabase
│   ├── exam_selection_screen.dart     # Selección de examen
│   ├── onboarding_screen.dart         # Walkthrough inicial
│   ├── exani_home_screen.dart         # Dashboard principal
│   ├── practice_setup_screen.dart     # Setup práctica (sección→área→skill)
│   ├── simulation_screen.dart         # Pre-simulacro
│   ├── exam_screen.dart               # Pantalla de examen
│   ├── diagnostic_result_screen.dart  # Resultados con análisis
│   ├── review_screen.dart             # Revisión post-examen
│   ├── guide_screen.dart              # Guía de estudio
│   ├── progress_screen.dart           # Estadísticas
│   ├── leaderboard_screen.dart        # Posiciones globales
│   ├── info_screen.dart               # Info general
│   ├── pro_screen.dart                # Premium
│   └── pdf_viewer_screen.dart         # Visor PDF
├── widgets/
│   ├── duo_button.dart                # Botón 3D Duolingo-style
│   ├── ad_banner_widget.dart          # Banner AdMob
│   ├── app_loader.dart                # Loaders profesionales
│   ├── content_image.dart             # Visor imágenes
│   └── exani_widgets.dart             # Widgets reutilizables
└── theme/
    └── app_theme.dart                 # AppColors + AppTheme
```

---

## 🔑 Funcionalidades Principales

| Funcionalidad           | Descripción                                                                |
| ----------------------- | -------------------------------------------------------------------------- |
| **Diagnóstico inicial** | Examen de 25-30 preguntas que identifica áreas débiles del usuario         |
| **Práctica dirigida**   | Drill-down por sección → área → habilidad para práctica enfocada           |
| **Simulacros**          | Examen de 168 preguntas con timer de 270 min (condiciones reales EXANI-II) |
| **Estadísticas**        | Tracking de precisión por área, habilidad y pregunta                       |
| **Leaderboard**         | Tabla de posiciones global con usuarios reales                             |
| **Guía de estudio**     | Visualización de todas las preguntas disponibles                           |

---

## 🗄️ Base de Datos (Supabase PostgreSQL)

### Jerarquía de Contenido

```
exams (EXANI-I, EXANI-II, etc.)
  └── exam_configs (reglas del examen: 168 preguntas, 270 min)
      └── sections (6 secciones)
          └── areas (múltiples áreas por sección)
              └── skills (habilidades específicas)
                  └── questions (preguntas individuales)
```

### Tablas de Usuario

- `user_profiles` - Perfil extendido del usuario
- `user_sessions` - Historial de prácticas/simulacros
- `user_area_stats` - Precisión por área
- `user_skill_stats` - Precisión por habilidad
- `user_question_stats` - Performance por pregunta
- `leaderboard` - Posiciones globales

### Estado Actual

- ✅ 2 exámenes configurados
- ✅ 13 secciones definidas
- ✅ 39 habilidades creadas
- ⚠️ Solo 3 preguntas (necesita seeding con content real)

---

## 🎯 SessionEngine

Motor reutilizable para tres modos de estudio:

| Modo           | Descripción                                     | Preguntas | Tiempo     |
| -------------- | ----------------------------------------------- | --------- | ---------- |
| **Diagnostic** | Evaluación inicial para identificar debilidades | 25-30     | Sin límite |
| **Practice**   | Práctica enfocada en sección/área/habilidad     | Variable  | Sin límite |
| **Simulation** | Examen completo con condiciones reales          | 168       | 270 min    |

**Características:**

- Selección inteligente de preguntas (evita repetición)
- Refresh automático de estadísticas al completar
- Soporte para trackeo de skillId en cada pregunta
  AdMob:\*\* Banners en screens principales, intersticiales estratégicos
- **Pro Version:** In-App Purchase para remover ads y desbloquear features Premium

---

## ✅ Estado Actual de Integración

**Completado:**

- ✅ Autenticación Supabase con Auth Gate
- ✅ Onboarding flow con persistencia
- ✅ Jerarquía completa en BD (exams→sections→areas→skills→questions)
- ✅ SessionEngine con 3 modos (diagnostic/practice/simulation)
- ✅ Sistema de caché con TTL
- ✅ Estadísticas por área y habilidad
- ✅ Leaderboard global
- ✅ Loaders profesionales estilo Duolingo
- ✅ Todas las pantallas usando datos de Supabase (no mock data)
- ✅ Question model con skillId para tracking

**Pendiente:**

- ⚠️ Seed de base de datos con preguntas reales EXANI-II
- ⚠️ Implementar SessionEngine UI screen (reemplazar ExamScreen actual)
- ⚠️ Invalidación de caché al agregar/modificar preguntas

---

## 📦 Dependencias Principales

| Paquete                     | Uso                       |
| --------------------------- | ------------------------- |
| `supabase_flutter`          | Backend + Auth + Database |
| `riverpod` / `flutter_bloc` | State management          |
| `go_router`                 | Navegación                |
| `google_mobile_ads`         | Monetización              |
| `in_app_purchase`           | Pro version               |
| `shared_preferences`        | Persistencia local        |
| `flutter_sound`             | Efectos de sonido         |

- **BannerAd:** Se muestra en HomeScreen, ExamScreen y GuideScreen
- **InterstitialAd:** Se muestra 3 segundos después de abrir PdfViewerScreen
- **IDs de producción configurados** (no test ads)
- Sin control de frecuencia de intersticiales

---

## ⚠️ Problemas Técnicos Identificados

1. **Modelo duplicado:** `Question` existe en `option.dart` y `question.dart` con campos diferentes
2. **`QuestionStat` sin uso:** Modelo preparado para estadísticas pero no implementado
3. **Directorio `services /` (con espacio):** Posible error de nombre
4. **Widgets vacío:** Sin componentes reutilizables extraídos
5. **Sin persistencia de datos:** No se guardan resultados, progreso ni preferencias
6. **Respuesta siempre id=1:** Todas las preguntas tienen `correctOptionId: 1`, el shuffle lo mitiga pero es un patrón predecible
7. **Aprobación requiere 10/10:** Umbral poco realista vs. el examen real
8. **Sin tema centralizado:** Colores hardcodeados repetidos (`0xFF121212`, `0xFF1E1E1E`)
9. **Sin manejo de estado:** Todo con setState básico
10. **Sin navegación con rutas nombradas**

---

## 📦 Dependencias

| Paquete                        | Uso                                  |
| ------------------------------ | ------------------------------------ |
| `url_launcher`                 | Declarado pero sin uso visible       |
| `syncfusion_flutter_pdfviewer` | Visor PDF embebido                   |
| `dio`                          | Descarga de PDF                      |
| `path_provider`                | Ruta de almacenamiento para descarga |
| `open_filex`                   | Abrir PDF descargado                 |
| `google_mobile_ads`            | Monetización AdMob                   |
| `flutter_native_splash`        | Splash screen personalizado          |
