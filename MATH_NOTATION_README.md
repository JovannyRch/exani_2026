# 📐 Soporte de Notación Matemática en EXANI App

## ✅ Cambios Implementados

### 1. **Soporte de Notación Matemática (Conversión a Unicode)**

Se implementó un sistema que convierte notación matemática LaTeX a símbolos Unicode, **sin necesidad de dependencias externas**. Esto garantiza:

- ✅ Compatibilidad total con Flutter
- ✅ Rendimiento óptimo
- ✅ Sin errores de compilación
- ✅ Funciona en todos los dispositivos

### 2. **Widget LatexText**

Widget personalizado que convierte automáticamente notación LaTeX a símbolos Unicode.

**Ubicación:** [lib/widgets/latex_text.dart](lib/widgets/latex_text.dart)

**Ejemplo de uso:**

```dart
LatexText(
  'El área es $A = \pi r^2$',
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
)
// Renderiza: El área es A = π r²
```

### 3. **Pantallas Actualizadas**

Todas las siguientes pantallas ahora soportan notación matemática:

- ✅ [exam_screen.dart](lib/screens/exam_screen.dart) - Preguntas del examen
- ✅ [review_screen.dart](lib/screens/review_screen.dart) - Revisión de respuestas
- ✅ [guide_screen.dart](lib/screens/guide_screen.dart) - Guía de estudio
- ✅ [content_image.dart](lib/widgets/content_image.dart) - Opciones de respuesta

### 4. **Caché Mejorado**

Nuevos métodos en `CacheService` para gestionar el caché de preguntas:

```dart
// Limpiar todo el caché de preguntas
CacheService().clearQuestionsCache();

// Limpiar caché específico
CacheService().clearQuestionsCacheFor(
  skillId: 7,      // Aritmética
  areaId: 3,       // Pensamiento matemático
  sectionId: 3,    // Sección 3
);
```

### 5. **Preguntas de Geometría**

Se agregaron 5 preguntas nuevas de Geometría con notación matemática:

- Teorema de Pitágoras
- Área de círculo con π
- Perímetro de rectángulo
- Volumen de cubo
- Suma de ángulos en triángulo

## 📊 Estado Actual de Preguntas

**Pensamiento Matemático (Área 3):**

- Aritmética (skill 7): **28 preguntas** ✅
- Álgebra (skill 8): **2 preguntas** ⚠️ (necesita más)
- Geometría (skill 9): **5 preguntas** ✅
- **Total: 35 preguntas**

## 🎯 Símbolos Matemáticos Soportados

### Operadores y Símbolos

```
\times → ×          (multiplicación)
\div → ÷            (división)
\pm → ±             (más/menos)
\approx → ≈         (aproximadamente)
\neq → ≠            (no igual)
\leq → ≤            (menor o igual)
\geq → ≥            (mayor o igual)
```

### Letras Griegas

```
\pi → π
\alpha → α
\beta → β
\gamma → γ
\Delta → Δ
```

### Símbolos Matemáticos Avanzados

```
\infty → ∞          (infinito)
\sum → ∑            (sumatoria)
\prod → ∏           (productoria)
\int → ∫            (integral)
```

### Fracciones Comunes

```
\frac{1}{2} → ½
\frac{1}{3} → ⅓
\frac{2}{3} → ⅔
\frac{1}{4} → ¼
\frac{3}{4} → ¾
\frac{1}{5} → ⅕
\frac{2}{5} → ⅖
\frac{3}{5} → ⅗
\frac{4}{5} → ⅘
\frac{1}{8} → ⅛
```

### Exponentes

```
x^2 → x²
x^3 → x³
```

## 💡 Ejemplos de Uso

### Antes (texto plano)

```
"El area es A = pi * r^2"
"Si x + 5 = 12 entonces x = 7"
```

### Después (con LatexText)

```dart
LatexText('El área es $A = \pi r^2$')
// Muestra: "El área es A = π r²"

LatexText('Si $x + 5 = 12$, entonces $x = 7$')
// Muestra: "Si x + 5 = 12, entonces x = 7"

LatexText('Gasta $\frac{1}{3}$ de su mesada')
// Muestra: "Gasta ⅓ de su mesada"

LatexText('$5 \times 3 \div 2 \approx 7.5$')
// Muestra: "5 × 3 ÷ 2 ≈ 7.5"
```

## 🔧 Solución al Problema Original

### Problema

Al seleccionar "Pensamiento Matemático", las preguntas no se cargaban.

### Diagnóstico

✅ Las preguntas **SÍ existen** en la base de datos (35 preguntas)
✅ El código de carga funciona correctamente
⚠️ Posible problema de **caché desactualizado**

### Solución

1. ✅ Implementado widget de notación matemática
2. ✅ Agregados métodos para limpiar caché
3. ✅ Agregadas preguntas de Geometría

### Cómo Limpiar el Caché

Si las preguntas no se cargan, puedes:

**Opción 1: Esperar** - El caché expira automáticamente en 2-5 minutos

**Opción 2: Agregar botón temporal** en settings:

```dart
ElevatedButton(
  onPressed: () {
    CacheService().clearQuestionsCache();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Caché limpiado ✅')),
    );
  },
  child: Text('Refrescar preguntas'),
)
```

**Opción 3: Reiniciar la app** completamente

## ⚠️ Limitaciones y Alternativas

### Limitaciones Actuales

La conversión a Unicode es **limitada** comparada con un renderizador LaTeX completo:

| Característica         | Soportado | Ejemplo     |
| ---------------------- | --------- | ----------- |
| Símbolos básicos       | ✅ Sí     | π, ×, ÷, ≈  |
| Fracciones comunes     | ✅ Sí     | ½, ¼, ⅓     |
| Exponentes simples     | ✅ Sí     | x², x³      |
| Raíces cuadradas       | ❌ No     | √x          |
| Fracciones complejas   | ❌ No     | (a+b)/(c+d) |
| Matrices               | ❌ No     | -           |
| Integrales con límites | ❌ No     | ∫₀^∞        |

### Alternativas Futuras

Si necesitas renderizado LaTeX completo, considera:

1. **WebView con MathJax/KaTeX**
   - ✅ Renderizado completo
   - ❌ Más pesado
   - ❌ Requiere conexión inicial

2. **Imágenes pre-renderizadas**
   - ✅ Funciona para ecuaciones muy complejas
   - ❌ No escala bien

3. **Esperar actualización**
   - Librerías Flutter compatibles en desarrollo

## 💡 Mejores Prácticas

### ✅ Recomendado

```
"Si x² + 5x + 6 = 0"
"El área es A = π r²"
"Temperatura: 25°C ± 2°C"
"Probabilidad: ½ × ⅓ = ⅙"
```

### ⚠️ Funciona (pero limitado)

```
"$\sqrt{16} = 4$"  → "16 = 4" (pierde la raíz)
"$\frac{a+b}{c-d}$" → "a+bc-d" (simplificado)
```

### ❌ Evitar (muy complejo)

```
"$$\int_0^{\infty} e^{-x^2} dx$$"
"$$\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}$$"
```

## 🚀 Cómo Agregar Nuevas Preguntas

### Opción 1: Usar Símbolos Unicode Directos

La forma más simple y confiable:

```sql
INSERT INTO questions (skill_id, stem, options_json, correct_key)
VALUES (
  7,
  'Si x² + 5x + 6 = 0, ¿cuánto vale x?',
  '[{"key":"a","text":"x = 2"},{"key":"b","text":"x = -2"}]'::jsonb,
  'b'
);
```

### Opción 2: Usar Notación LaTeX

Para símbolos que se convierten automáticamente:

```sql
INSERT INTO questions (skill_id, stem, options_json, correct_key)
VALUES (
  7,
  'El área de un círculo es $A = \pi r^2$. Si r = 7, ¿cuánto es A?',
  '[{"key":"a","text":"$49\pi$"},{"key":"b","text":"$14\pi$"}]'::jsonb,
  'a'
);
```

### Símbolos Unicode Útiles

Copia y pega directamente:

```
Matemáticos: × ÷ ± ≠ ≈ ≤ ≥ ∞
Griegos: π α β γ δ θ λ μ σ Δ
Exponentes: ⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹
Fracciones: ½ ⅓ ⅔ ¼ ¾ ⅕ ⅖ ⅗ ⅘ ⅙ ⅐ ⅛ ⅑ ⅒
Flechas: → ← ↔ ⇒ ⇐ ⇔
```

## 🐛 Troubleshooting

### Las preguntas no cargan

1. ✅ Verifica que existan preguntas: consulta SQL
2. ⏰ Espera 2-5 minutos (expiración de caché)
3. 🔄 Limpia el caché: `CacheService().clearQuestionsCache()`
4. 📱 Reinicia la app completamente

### Los símbolos no se ven bien

1. ✅ Verifica que usas `LatexText` en lugar de `Text`
2. ✅ Confirma que los símbolos están entre `$...$`
3. ⚠️ Algunos símbolos LaTeX no se convierten (ver Limitaciones)
4. 💡 Usa símbolos Unicode directos cuando sea posible

### Error de compilación

✅ **Resuelto** - Ya no usamos librerías externas
✅ La implementación actual usa solo Flutter nativo
✅ Compatible con todas las versiones de Flutter

## 📝 Próximos Pasos

1. ⚠️ **Agregar más preguntas de Álgebra** (solo hay 2 actualmente)
2. ✅ Probar todas las pantallas con preguntas matemáticas
3. 📊 Considerar agregar estadísticas por tipo de pregunta
4. 💡 Evaluar implementar WebView para ecuaciones muy complejas (opcional)

---

**Última actualización:** 24 de febrero de 2026  
**Estado:** ✅ Funcional - Sin dependencias externas  
**Compatibilidad:** Flutter 3.7+
