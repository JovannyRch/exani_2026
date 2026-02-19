# 📚 Skill ID Reference Guide

Quick reference for `skill_id` values when adding questions to the database.

## EXANI-II Skills

### 1️⃣ Comprensión Lectora (Section 1)

- **1** - Identificar idea principal
- **2** - Hacer inferencias
- **3** - Identificar propósito

### 2️⃣ Redacción Indirecta (Section 2)

- **4** - Ortografía
- **5** - Sintaxis
- **6** - Cohesión textual

### 3️⃣ Pensamiento Matemático (Section 3)

- **7** - Aritmética
- **8** - Álgebra
- **9** - Geometría

### 4️⃣ Física (Section 4)

- **10** - Mecánica
- **11** - Termodinámica
- **12** - Ondas

### 5️⃣ Química (Section 5)

- **13** - Estructura atómica
- **14** - Enlaces químicos
- **15** - Reacciones químicas

### 6️⃣ Probabilidad y Estadística (Section 6)

- **16** - Estadística descriptiva
- **17** - Probabilidad
- **18** - Estadística inferencial

### 7️⃣ Administración (Section 7)

- **19** - Proceso administrativo
- **20** - Teoría de organizaciones
- **21** - Recursos humanos

### 8️⃣ Inglés Diagnóstico (Section 8)

- **22** - Reading comprehension
- **23** - Grammar
- **24** - Vocabulary

---

## EXANI-I Skills

### 9️⃣ Pensamiento Matemático (Section 9)

- **25** - Aritmética
- **26** - Álgebra básica
- **27** - Geometría básica

### 🔟 Pensamiento Científico (Section 10)

- **28** - Método científico
- **29** - Biología básica
- **30** - Física básica

### 1️⃣1️⃣ Comprensión Lectora (Section 11)

- **31** - Identificar idea principal
- **32** - Identificar detalles
- **33** - Vocabulario en contexto

### 1️⃣2️⃣ Redacción Indirecta (Section 12)

- **34** - Ortografía básica
- **35** - Puntuación
- **36** - Coherencia

### 1️⃣3️⃣ Inglés Diagnóstico (Section 13)

- **37** - Reading A2
- **38** - Grammar A2
- **39** - Vocabulary A2

---

## 📊 Distribución Recomendada (168 Preguntas - Simulacro EXANI-II)

Para un simulacro completo del EXANI-II, distribuye las 168 preguntas así:

| Sección                | # Preguntas | Skills recomendados |
| ---------------------- | ----------- | ------------------- |
| Comprensión lectora    | 30          | 1-3 (10 c/u)        |
| Redacción indirecta    | 30          | 4-6 (10 c/u)        |
| Pensamiento matemático | 30          | 7-9 (10 c/u)        |
| Módulo 1 (ej: Física)  | 24          | 10-12 (8 c/u)       |
| Módulo 2 (ej: Química) | 24          | 13-15 (8 c/u)       |
| Inglés (diagnóstico)   | 30          | 22-24 (10 c/u)      |
| **TOTAL**              | **168**     |                     |

---

## 🎯 Ejemplo de Uso Rápido

```sql
-- Pregunta de Aritmética (skill_id = 7)
INSERT INTO questions (skill_id, set_id, stem, options_json, correct_key, explanation, difficulty)
VALUES (
  7,  -- Aritmética
  1,  -- Set EXANI-II v1.0
  '¿Cuánto es 25% de 80?',
  '[
    {"key": "a", "text": "15", "image": null},
    {"key": "b", "text": "20", "image": null},
    {"key": "c", "text": "25", "image": null}
  ]'::jsonb,
  'b',
  '80 × 0.25 = 20',
  'easy'
);
```

---

## 📝 Verificar Skills Disponibles

```sql
-- Ver todos los skills con sus IDs
SELECT
  sk.id,
  sk.name,
  a.name AS area,
  s.name AS section
FROM skills sk
JOIN areas a ON sk.area_id = a.id
JOIN sections s ON a.section_id = s.id
WHERE sk.is_active = true
ORDER BY sk.id;
```
