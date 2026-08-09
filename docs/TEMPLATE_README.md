# 🚀 Flutter Quiz/Exam App — Template Base

> Template base con diseño Duolingo-inspired para crear apps de exámenes, quizzes y guías de estudio.

---

## ✨ Características incluidas

- 🎨 **Diseño Duolingo-inspired** — Botones 3D, animaciones escalonadas, paleta verde vibrante
- 🌙 **Dark/Light Mode** — Con persistencia automática
- 📊 **Progreso y estadísticas** — SQLite local, gráficas, racha de estudio
- 💰 **Monetización** — AdMob (banner + interstitial) + In-App Purchase (versión Pro)
- 📱 **Notificaciones** — Recordatorios diarios configurables
- 📄 **Visor de PDF** — Para guías descargables
- ⭐ **Favoritos** — Guardar preguntas manualmente o automáticamente (falladas)
- 🔊 **Efectos de sonido** — Feedback táctil con audio
- 📤 **Compartir resultados** — Share nativo
- ⭐ **Rating prompt** — Solicitud inteligente de calificación

---

## 📋 Inicio Rápido

### 1. Clonar y Setup

```bash
git clone <repo-url> mi_nueva_app
cd mi_nueva_app

# Setup rápido (cambia IDs, nombre y proyecto)
./commands.sh setup com.miempresa.miapp "Mi App de Examen" mi_app_examen
```

### 2. Personalizar Datos

Edita `lib/data/data.dart` con tus preguntas:

```dart
final List<Question> questions = [
  Question(
    id: 1,
    category: 'Categoría',
    question: '¿Tu pregunta aquí?',
    options: [
      Option(text: 'Respuesta correcta', isCorrect: true),
      Option(text: 'Distractor 1', isCorrect: false),
      Option(text: 'Distractor 2', isCorrect: false),
    ],
    explanation: 'Explicación de por qué la respuesta es correcta.',
  ),
  // más preguntas...
];
```

### 3. Configurar AdMob

1. Crea una app en [AdMob](https://admob.google.com/)
2. Obtén los IDs de ad units (banner + interstitial)
3. Ejecuta:

```bash
./commands.sh change-admob-ids ca-app-pub-XXXX~YYYY ca-app-pub-XXXX/BBBB ca-app-pub-XXXX/IIII
```

### 4. Configurar In-App Purchase

1. Crea una **suscripción** en Google Play Console con ID `pro_monthly`,
   con un plan base **mensual auto-renovable** a **$49.00 MXN**
2. O cambia el ID:

```bash
./commands.sh change-iap-product mi_producto_pro
```

### 5. Assets

Reemplaza los archivos en `assets/`:

- `assets/logo.png` — Logo de la app (se usa en splash)
- `assets/files/guia_manejo.pdf` — Tu PDF de guía (o elimina la funcionalidad)
- `assets/sounds/` — Archivos de sonido (.mp3)

### 6. Configurar Examen

```bash
# Duración en minutos, total de preguntas, puntaje aprobatorio
./commands.sh change-exam-config 10 20 14
```

### 7. URLs

```bash
./commands.sh change-playstore-url "https://play.google.com/store/apps/details?id=com.miempresa.miapp"
./commands.sh change-pdf-url "https://tu-servidor.com/guia.pdf"
```

### 8. Splash Screen

```bash
./commands.sh change-splash-color "#1B1B2F"
./commands.sh generate-splash
```

### 9. Build

```bash
# Verificar configuración
./commands.sh checklist

# En desarrollo (ads de prueba)
./commands.sh toggle-test-ads true

# Para publicar
./commands.sh toggle-test-ads false
./commands.sh build-aab
```

---

## 📁 Estructura del Proyecto

```
lib/
├── main.dart              # Entry point
├── const/const.dart       # Constantes globales
├── theme/app_theme.dart   # Sistema de colores y tema
├── models/                # Modelos de datos
├── data/data.dart         # Preguntas y categorías ← PERSONALIZAR
├── services/              # 6 servicios singleton
├── screens/               # 10 pantallas
└── widgets/               # Componentes reutilizables
```

---

## 🎨 Documentación

| Documento                                      | Descripción                                                        |
| ---------------------------------------------- | ------------------------------------------------------------------ |
| [docs/DESIGN_SYSTEM.md](docs/DESIGN_SYSTEM.md) | Paleta de colores, tipografía, componentes, animaciones, espaciado |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)   | Servicios, patrones, dependencias, configuración Android           |

---

## 🛠 Comandos Disponibles

```bash
./commands.sh help          # Ver todos los comandos

# Setup
./commands.sh setup <id> <"nombre"> <proyecto>   # Setup completo
./commands.sh info                                # Ver configuración actual
./commands.sh checklist                           # Checklist pre-deploy

# Configuración
./commands.sh change-app-id com.company.app       # Android App ID
./commands.sh change-app-name "Mi App"            # Nombre visible
./commands.sh change-version 1.2.0 15             # Versión
./commands.sh bump-build                           # Incrementar build +1
./commands.sh rename-project mi_app               # Renombrar proyecto

# Monetización
./commands.sh change-admob-ids APP BANNER INTER   # AdMob IDs
./commands.sh toggle-test-ads true|false           # Ads de prueba
./commands.sh change-iap-product product_id        # Producto premium

# Contenido
./commands.sh change-exam-config 10 20 14          # Config de examen
./commands.sh change-pdf-url "https://..."         # URL del PDF
./commands.sh change-playstore-url "https://..."   # URL Play Store

# Build
./commands.sh clean                                # Limpiar proyecto
./commands.sh generate-splash                      # Generar splash
./commands.sh build-apk                            # Build APK
./commands.sh build-aab                            # Build AAB
```

---

## ⚙️ Requisitos

- Flutter SDK `^3.7.0`
- Android Studio / VS Code
- Cuenta Google Play Console (para publicar)
- Cuenta AdMob (para monetización)
- `key.properties` configurado (para release signing)

---

## 📝 Checklist de Nueva App

- [ ] Ejecutar `./commands.sh setup ...`
- [ ] Personalizar `lib/data/data.dart` con preguntas
- [ ] Reemplazar `assets/logo.png`
- [ ] Reemplazar o eliminar `assets/files/guia_manejo.pdf`
- [ ] Configurar AdMob IDs
- [ ] Configurar IAP product en Google Play Console
- [ ] Actualizar URLs (Play Store, PDF)
- [ ] Configurar `key.properties` para signing
- [ ] Personalizar textos en pantallas (subtítulos, nombres de secciones)
- [ ] Personalizar `Info Screen` con información relevante
- [ ] Actualizar splash screen
- [ ] Test con `./commands.sh checklist`
- [ ] Build con `./commands.sh build-aab`
