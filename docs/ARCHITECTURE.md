# 🏗️ Arquitectura — Base Template

> Referencia técnica de la arquitectura, servicios y patrones del proyecto.

---

## 1. Estructura de Carpetas

```
lib/
├── main.dart                 # Entry point, inicialización de servicios
├── const/
│   └── const.dart            # Constantes globales (URLs, config del examen)
├── theme/
│   └── app_theme.dart        # AppColors + AppTheme (light/dark)
├── models/
│   ├── option.dart           # Question y Option models (con skillId)
│   ├── exam_result.dart      # Modelo de resultado de examen
│   ├── question_stat.dart    # Estadísticas por pregunta
│   ├── session.dart          # SessionConfig y SessionMode
│   └── leaderboard.dart      # Leaderboard entries
├── services/
│   ├── supabase_service.dart         # Cliente Supabase con helpers
│   ├── supabase_session_repository.dart # Implementación Supabase del repo
│   ├── session_repository.dart       # Interface para session data
│   ├── session_engine.dart           # Motor de sesiones (diagnostic/practice/simulation)
│   ├── question_selector.dart        # Selección inteligente de preguntas
│   ├── cache_service.dart            # Caché con TTL (in-memory + SharedPreferences)
│   ├── leaderboard_service.dart      # Tabla de posiciones global
│   ├── theme_service.dart            # Persistencia de tema dark/light
│   ├── admob_service.dart            # Ads (banner + interstitial)
│   ├── sound_service.dart            # Efectos de sonido
│   ├── notification_service.dart     # Recordatorios diarios
│   ├── purchase_service.dart         # In-app purchase (Pro version)
│   └── database_service.dart         # SQLite (resultados + favoritos)
├── screens/
│   ├── auth_gate.dart                # Control de autenticación y onboarding
│   ├── auth_screen.dart              # Login/Registro con Supabase Auth
│   ├── exam_selection_screen.dart    # Selección de examen inicial
│   ├── onboarding_screen.dart        # Walkthrough inicial
│   ├── exani_home_screen.dart   # Botón 3D estilo Duolingo
    ├── ad_banner_widget.dart    # Banner de AdMob reutilizable
    ├── app_loader.dart          # Loaders profesionales estilo Duolingo
    ├── content_image.dart       # Visor de imágenes en preguntas
    └── exani_widgets.dart       # Widgets reutilizablesección→área→skill)
│   ├── simulation_screen.dart        # Pre-simulacro con reglas
│   ├── exam_screen.dart              # Pantalla de examen con timer
│   ├── diagnostic_result_screen.dart # Resultados con análisis de áreas
│   ├── review_screen.dart            # Revisión post-examen
│   ├── guide_screen.dart             # Guía de estudio (todas las preguntas)
│   ├── progress_screen.dart          # Estadísticas y gráficas
│   ├── leaderboard_screen.dart       # Tabla de posiciones
│   ├── favorites_screen.dart         # Preguntas guardadas
│   ├── info_screen.dart              # Información general
│   ├── pro_screen.dart               # Pantalla de compra Premium
│   └── pdf_viewer_screen.dart        # Visor de PDF
└── widgets/
    ├── duo_button.dart       # Botón 3D estilo Duolingo
    └── ad_banner_widget.dart # Banner de AdMob reutilizable
```

---

## 2. Servicios (Singleton Pattern)

Todos los servicios usan el patrón singleton de Dart:

```dart
class MyService {
  static final MyService _instance = MyService._internal();
  factory MyService() => _instance;
  MyService._internal();

  Future<void> initialize() async { ... }
}
```

### Orden de Inicialización (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService().initialize();      // 1. Tema (necesario antes de build)
  await AdMobService.initialize();         // 2. Ads
  await SoundService().initialize();       // 3. Sonidos
  await NotificationService().initialize();// 4. Notificaciones
  await PurchaseService().initialize();    // 5. Compras
  runApp(const MyApp());
}
```

> **Nota:** `DatabaseService` se inicializa lazy (al primer acceso).

### 2.1 ThemeService

| Propiedad       | Tipo                       | Descripción                    |
| --------------- | -------------------------- | ------------------------------ |
| `themeMode`     | `ValueNotifier<ThemeMode>` | Estado del tema (light/dark)   |
| `isDark`        | `bool` getter              | Shortcut para saber si es dark |
| `toggleTheme()` | `Future<void>`             | Alterna y persiste             |

**Persistencia:** `SharedPreferences` key `theme_mode` (valores: `"light"`, `"dark"`)

**Integración con MaterialApp:**

```dart
ValueListenableBuilder<ThemeMode>(
  valueListenable: ThemeService().themeMode,
  builder: (context, mode, _) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: mode,
    );
  },
)
```

### 2.2 AdMobService (Clase Estática)

A diferencia de los demás, este es una clase con métodos estáticos.

| Método                   | Retorna                   | Descripción                              |
| ------------------------ | ------------------------- | ---------------------------------------- |
| `initialize()`           | `Future<void>`            | Inicializa MobileAds SDK                 |
| `createBannerAd()`       | `BannerAd`                | Crea banner para pantallas               |
| `createInterstitialAd()` | `Future<InterstitialAd?>` | Carga interstitial (async con Completer) |
| `showInterstitialAd(ad)` | `void`                    | Muestra y dispone el interstitial        |

**Configuración de IDs:**

```dart
static const bool _testAds = true; // ← Cambiar a false para producción

// IDs de prueba (Google proporcionados)
static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

// IDs reales (reemplazar por los tuyos)
static const String _prodBannerAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
static const String _prodInterstitialAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX';
```

**Patrón Completer para Interstitial:**

```dart
static Future<InterstitialAd?> createInterstitialAd() async {
  final Completer<InterstitialAd?> completer = Completer();
  await InterstitialAd.load(
    adUnitId: interstitialAdUnitId,
    request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (ad) => completer.complete(ad),
      onAdFailedToLoad: (_) => completer.complete(null),
    ),
  );
  return completer.future;
}
```

### 2.3 SoundService

| Método      | Descripción             |
| ----------- | ----------------------- |
| `playTap()` | Reproduce sonido de tap |

**Assets requeridos:** Archivos `.mp3` en `assets/sounds/`.

### 2.4 NotificationService

| Método                                      | Descripción                     |
| ------------------------------------------- | ------------------------------- |
| `requestPermissions()`                      | Solicita permisos al SO         |
| `scheduleDailyReminder(hour, minute)`       | Programa notificación diaria    |
| `cancelReminder()`                          | Cancela la notificación         |
| `isReminderEnabled()`                       | `Future<bool>` — si está activo |
| `getReminderHour()` / `getReminderMinute()` | Hora guardada                   |

**Persistencia:** `SharedPreferences`

### 2.5 PurchaseService

| Propiedad            | Tipo                     | Descripción               |
| -------------------- | ------------------------ | ------------------------- |
| `isPro`              | `ValueNotifier<bool>`    | Estado premium observable |
| `isProUser`          | `bool` getter            | Acceso directo            |
| `onMessage`          | `void Function(String)?` | Callback para UI          |
| `buyPro()`           | `Future<void>`           | Inicia compra             |
| `restorePurchases()` | `Future<void>`           | Restaura compras          |

**Product ID:** `kProProductId = 'pro_version'` (non-consumable)

**Persistencia:** `SharedPreferences` key `is_pro` como caché offline.

**Patron de uso en widgets:**

```dart
ValueListenableBuilder<bool>(
  valueListenable: PurchaseService().isPro,
  builder: (context, isPro, _) {
    if (isPro) return SizedBox.shrink();
    return AdBannerWidget();
  },
)
```

### 2.6 DatabaseService

**SQLite v2** con dos tablas:

```sql
CREATE TABLE exam_results (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  correct_answers INTEGER NOT NULL,
  total_questions INTEGER NOT NULL,
  passed INTEGER NOT NULL,
  time_spent_seconds INTEGER NOT NULL,
  date TEXT NOT NULL
);

CREATE TABLE favorite_questions (
  question_id INTEGER PRIMARY KEY,
  source TEXT NOT NULL DEFAULT 'manual',
  date_added TEXT NOT NULL
);
```

| Método                               | Descripción                                |
| ------------------------------------ | ------------------------------------------ |
| `insertExamResult(result)`           | Guarda resultado                           |
| `getAllResults()`                    | Todos los resultados (newest first)        |
| `getLastResults(count)`              | Últimos N resultados                       |
| `getAllStats()`                      | Map con totalExams, bestScore, streak, etc |
| `getStudyStreak()`                   | Racha de días consecutivos                 |
| `toggleFavorite(questionId, source)` | Toggle guardado                            |
| `isFavorite(questionId)`             | `Future<bool>`                             |
| `getFavoriteIds()`                   | Set de IDs favoritos                       |

**Fuente de favoritos (`source`):** `'manual'` (usuario guardó) o `'failed'` (falló en examen).

---

## 3. State Management

**NO se usa ningún paquete externo** (ni Provider, ni Riverpod, ni Bloc).

### Patrón: ValueNotifier + ValueListenableBuilder

```dart
// En el servicio:
final ValueNotifier<bool> isPro = ValueNotifier<bool>(false);

// En el widget:
ValueListenableBuilder<bool>(
  valueListenable: PurchaseService().isPro,
  builder: (context, isPro, _) {
    return Text(isPro ? 'Pro' : 'Free');
  },
)
```

### Patrón: setState + Future.then

Para recargar datos al regresar de una pantalla:

```dart
Navigator.push(context, _slideRoute(OtherScreen()))
    .then((_) => _loadStats()); // recarga al volver
```

---

## 4. Navegación

Todas las transiciones usan slide desde la derecha:

```dart
Route _slideRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      );
    },
  );
}
```

**Uso:** `Navigator.push(context, _slideRoute(TargetScreen()))`.

---

## 5. Integración de Ads

### Banner Ads

Se coloca `AdBannerWidget()` al fondo de cada pantalla dentro de la estructura estándar:

```dart
Column(
  children: [
    Expanded(child: SingleChildScrollView(...)),
    const AdBannerWidget(), // ← aquí
  ],
)
```

**Pantallas con banner:** HomeScreen, GuideScreen, CategoryScreen, FavoritesScreen, ProgressScreen.

### Interstitial Ads

Se cargan al entrar a la pantalla y se muestran en momentos clave.

```dart
// En initState:
InterstitialAd? _interstitialAd;

@override
void initState() {
  super.initState();
  AdMobService.createInterstitialAd().then((ad) {
    _interstitialAd = ad;
  });
}

// Al mostrar (ej. al salir o después de completar acción):
if (_interstitialAd != null) {
  AdMobService.showInterstitialAd(_interstitialAd);
}
```

**Pantallas con interstitial:** ResultsScreen (2s delay), ReviewScreen (al salir), PdfViewerScreen.

**⚠️ Importante:** Guardar `Navigator` reference ANTES de async gap para evitar uso de `BuildContext` después de `await`:

```dart
final navigator = Navigator.of(context);
await Future.delayed(Duration(seconds: 2));
AdMobService.showInterstitialAd(_interstitialAd);
navigator.pop();
```

---

## 6. Constantes Globales (const.dart)

```dart
const String PDF_URL = "https://...";
const String PLAYSTORE_APP_ID = "https://play.google.com/store/apps/details?id=com.example.app";

const int EXAM_DURATION_MINUTES = 5;
const int EXAM_TOTAL_QUESTIONS = 10;
const int EXAM_PASSING_SCORE = 6;
const double EXAM_PASSING_PERCENTAGE = (EXAM_PASSING_SCORE / EXAM_TOTAL_QUESTIONS) * 100;
```

**Regla:** Todo valor que se usa en más de un archivo DEBE ir aquí.

---

## 7. Modelos de Datos

### Question

```dart
class Question {
  final int id;
  final String category;
  final String question;
  final List<Option> options;
  final String explanation;
}
```

### Option

```dart
class Option {
  final String text;
  final bool isCorrect;
}
```

### ExamResult (SQLite)

```dart
class ExamResult {
  final int? id;
  final int correctAnswers;
  final int totalQuestions;
  final bool passed;
  final int timeSpentSeconds;
  final String date;

  Map<String, dynamic> toMap() => { ... };
  factory ExamResult.fromMap(Map<String, dynamic> map) => ...;
}
```

---

## 8. Android Configuration

### build.gradle.kts (app)

```kotlin
android {
    namespace = "com.example.your_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true  // ← required for modern APIs
    }

    defaultConfig {
        applicationId = "com.yourcompany.yourapp"  // ← CAMBIAR
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

### AndroidManifest.xml

Permisos requeridos:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="com.android.vending.BILLING"/>
```

- `INTERNET` — Ads, descargas PDF, etc.
- `BILLING` — Google Play In-App Purchase.

### Signing

Se usa `key.properties` (NO commitear) con referencia en `build.gradle.kts`:

```properties
storePassword=xxx
keyPassword=xxx
keyAlias=xxx
storeFile=path/to/keystore.jks
```

---

## 9. Dependencias Clave

| Paquete                        | Versión    | Uso                                           |
| ------------------------------ | ---------- | --------------------------------------------- |
| `google_mobile_ads`            | `^5.1.0`   | Banner + Interstitial ads                     |
| `sqflite`                      | `^2.4.2`   | Base de datos local                           |
| `shared_preferences`           | `^2.5.3`   | Persistencia simple (tema, pro, recordatorio) |
| `in_app_purchase`              | `^3.2.3`   | Compras in-app                                |
| `fl_chart`                     | `^0.70.2`  | Gráficas de progreso                          |
| `audioplayers`                 | `^6.1.0`   | Efectos de sonido                             |
| `flutter_local_notifications`  | `^19.5.0`  | Recordatorios                                 |
| `timezone`                     | `^0.10.1`  | Zonas horarias para notificaciones            |
| `syncfusion_flutter_pdfviewer` | `^31.1.19` | Visor de PDF                                  |
| `dio`                          | `^5.9.0`   | Descarga de archivos                          |
| `path_provider`                | `^2.1.5`   | Paths del sistema                             |
| `open_filex`                   | `^4.7.0`   | Abrir archivos externos                       |
| `url_launcher`                 | `^6.3.2`   | Abrir URLs                                    |
| `share_plus`                   | `^12.0.1`  | Compartir resultados                          |
| `in_app_review`                | `^2.0.11`  | Prompt de calificación                        |
| `intl`                         | `^0.19.0`  | Formato de fechas                             |
| `flutter_native_splash`        | `^2.4.6`   | Splash screen (dev only)                      |

---

## 10. Patrones Importantes

### Patrón: Async Gap Safety

Al usar `Navigator` o `ScaffoldMessenger` después de `await`:

```dart
// ✅ Correcto
final navigator = Navigator.of(context);
await someAsyncWork();
navigator.pop();

// ❌ Incorrecto — context puede ser inválido
await someAsyncWork();
Navigator.of(context).pop();
```

### Patrón: Mounted Check

Después de cualquier async en un State:

```dart
final data = await fetchData();
if (mounted) {
  setState(() => _data = data);
}
```

### Patrón: Reload on Return

Para refrescar datos al regresar de pantalla:

```dart
Navigator.push(context, route).then((_) => _loadData());
```

### Patrón: No const con AppColors dinámicos

Los neutros de `AppColors` son getters (no const). Cualquier widget que los use no puede ser `const`:

```dart
// ❌ Error de compilación
const Text('Hello', style: TextStyle(color: AppColors.textPrimary))

// ✅ Correcto
Text('Hello', style: TextStyle(color: AppColors.textPrimary))
```

Los colores de acento (`AppColors.primary`, etc.) sí son `const`.
