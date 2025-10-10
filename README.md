```
assets/logo.png
```

# 📱 Examen de Manejo EdoMex

Aplicación móvil en **Flutter** para ayudar a estudiar y simular el examen teórico de la **licencia de manejo en el Estado de México**.
Incluye la guía oficial con preguntas y un simulador de examen con cronómetro, resultados y retroalimentación.

---

## 🚀 Características

- 📘 **Guía de estudio**

  - Todas las preguntas de la guía oficial (54).
  - Preguntas con texto e imágenes (señales de tránsito).
  - Swipe horizontal tipo _PageView_ para pasar entre preguntas.
  - Respuesta correcta resaltada.

- 📝 **Simulador de examen**

  - 10 preguntas aleatorias de la guía.
  - Opciones en desorden.
  - Cronómetro de **30 minutos** ⏱.
  - Resultados al final: número de aciertos y si aprobaste (mínimo 8 correctas).

- 🎨 **Diseño moderno en modo oscuro**

  - UI minimalista con tarjetas y acentos de color.
  - Pensada para usabilidad y enfoque en el estudio.

---

<!-- ## 📷 Screenshots

Ejemplo:

```
assets/screenshots/home.png
assets/screenshots/exam.png
assets/screenshots/guide.png
```
 -->

---

## 🛠 Tecnologías

- [Flutter](https://flutter.dev/) (3.x)
- [Dart](https://dart.dev/)
- Android (Play Store)

---

## 📦 Instalación y ejecución

1. Clonar el repositorio:

   ```bash
   git clone https://github.com/JovannyRch/examen_vial_edomex_2025
   cd examen_vial_edomex_2025
   ```

2. Instalar dependencias:

   ```bash
   flutter pub get
   ```

3. Ejecutar en un dispositivo/emulador:

   ```bash
   flutter run
   ```

4. Generar release para Play Store:

   ```bash
   flutter build appbundle --release
   ```

---

## 📌 Roadmap

- [x] Pantalla de guía de estudio (con swipe).
- [x] Pantalla de examen con cronómetro y resultados.
- [ ] Estadísticas e historial de intentos.
- [ ] Configuración (tema, reinicio de progreso).
- [ ] Soporte multilenguaje (español/inglés).

---

## 📝 Licencia

Este proyecto se distribuye bajo la licencia **MIT**.
El contenido de la guía pertenece a la **Secretaría de Movilidad del Estado de México**.

---
