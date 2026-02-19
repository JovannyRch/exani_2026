-- ═══════════════════════════════════════════════════════════════════════════════
-- EXANI Prep — Seed Questions (Batch Import)
-- Uso: Copiar y pegar en Supabase SQL Editor
-- ═══════════════════════════════════════════════════════════════════════════════

-- INSTRUCCIONES:
-- 1. Abre Supabase Dashboard → SQL Editor
-- 2. Crea una nueva query
-- 3. Pega este contenido completo
-- 4. Ejecuta (Run)

-- ─── PREGUNTAS: COMPRENSIÓN LECTORA (skill_id = 1) ─────────────────────────

INSERT INTO questions (skill_id, set_id, stem, options_json, correct_key, explanation, difficulty, tags_json) VALUES

-- Pregunta 1
(1, 1, 
 '¿Qué herramienta se emplea en la teoría de la calidad para el análisis de problemas?',
 '[
   {"key": "a", "text": "Pirámide de Maslow", "image": null},
   {"key": "b", "text": "Gráfica de Gantt", "image": null},
   {"key": "c", "text": "Diagrama de espina de pescado", "image": null}
 ]'::jsonb,
 'b',
 '',
 'easy',
 '["comprension_lectora", "idea_principal"]'::jsonb),

-- Pregunta 2
(1, 1,
 '¿Qué tipo de empresa es una panadería con 30 empleados?',
 '[
   {"key": "a", "text": "Micro", "image": null},
   {"key": "b", "text": "Pequeña ", "image": null},
   {"key": "c", "text": "Mediana", "image": null}
 ]'::jsonb,
 'b',
 '',
 'medium',
 '["comprension_lectora", "inferencias"]'::jsonb);
 
 
 INSERT INTO questions (skill_id, set_id, stem, options_json, correct_key, explanation, difficulty, tags_json) VALUES

(4, 1,
 '¿A qué tipo de organización corresponde una empresa que produce zapatos?',
 '[
   {"key": "a", "text": "Industrial", "image": null},
   {"key": "b", "text": "Comercial", "image": null},
   {"key": "c", "text": "De servicios", "image": null},
 ]'::jsonb,
 'a',
 'La actividad primordial de este tipo de empresas es la producción de bienes mediante la transformación o extracción de materia primas.',
 'easy',
 '["ortografia", "acentuacion"]'::jsonb),
(4, 1,
 '¿Qué área funcional es la encargada de la logística de abastecimiento?',
 '[
   {"key": "a", "text": "Mercadotecnia", "image": null},
   {"key": "b", "text": "Finanzas", "image": null},
   {"key": "c", "text": "Producción", "image": null},
 ]'::jsonb,
 'c',
 'El área funcional a la que corresponden las actividades propuestas en la pregunta base son de producción, porque es la encargada de las operaciones de compra y logística de abastecimiento, control de calidad, seguridad, higiene e ingeniería de proyectos.',
 'easy',
 '["area_funcional"]'::jsonb),
(4, 1,
 'Ordene cronológicamente las actividades del reclutamiento de personal.

1. Formalizar la relación de trabajo con apego a la ley
2. Introducir al personal al ámbito organizacional de la empresa
3. Atender a los candidatos potencialmente calificados
4. Elegir los elementos que garantizan el sistema de trabajo de la empresa',
 '[
   {"key": "a", "text": "3, 4, 1, 2", "image": null},
   {"key": "b", "text": "3, 4, 2, 1", "image": null},
   {"key": "c", "text": "4, 3, 1, 2", "image": null},
 ]'::jsonb,
 'a',
 '3, 4, 1, 2: El reclutamiento de personal es una actividad que hace el Área de Recursos Humanos y se lleva a cabo en el siguiente orden: primero se busca y se atiende a los candidatos potencialmente calificados y capaces de ocupar cargos dentro de la organización (3); luego sigue la selección de personal, es decir, elegir a los elementos que garantizan la adaptación al estilo, estructura y sistema de trabajo de la empresa (4); sigue la contratación que permite formalizar la relación de trabajo con apego a la ley para garantizar los derechos y obligaciones del trabajador y de la empresa (1). Finalmente, se realiza la inducción en la que se debe realizar una introducción del personal al ámbito organizacional de la empresa, el cual implica al ambiente de trabajo, el clima de las relaciones humanas, sus prácticas, etc. (2).',
 'easy',
 '["cronologia"]'::jsonb),

 (4, 1,
 'La Dirección General de una empresa presenta el reporte trimestral de ventas a sus inversionistas. Ellos notan que la información no corresponde con los cortes mensuales que se habían revisado y avalado previamente, por lo que solicitan que la información sea corregida y presentada de nuevo.

¿A qué área funcional de la empresa corresponde corregir?',
 '[
   {"key": "a", "text": "Ventas", "image": null},
   {"key": "b", "text": "Mercadotecnia", "image": null},
   {"key": "c", "text": "Finanzas", "image": null},
 ]'::jsonb,
 'c',
 'Esta área funcional dentro de sus funciones se encarga de llevar un registro de todos los movimientos que se llevan a cabo dentro de las empresas, incluyendo las ventas que éstas realizan; a su vez con base en esta información es el área responsable de preparar y elaborar reportes pormenorizados con dicha información para facilitar la toma de decisiones de quienes están a cargo de la organización.',
 'easy',
 '["area_funcional"]'::jsonb),
 
 (4, 1,
 'Capacidad del emprendedor por medio de la cual las ideas son generadas, desarrolladas y transformadas para generar un valor agregado.',
 '[
   {"key": "a", "text": "Creatividad", "image": null},
   {"key": "b", "text": "Determinación", "image": null},
   {"key": "c", "text": "Tenacidad", "image": null},
 ]'::jsonb,
 'a',
 'La creatividad es el proceso por medio del cual las ideas de negocio son generadas, desarrolladas y transformadas en valor agregado. No es necesario inventar lo que ya esta inventado, pero sí es necesario identificar nuevas posibilidades de hacer las cosas y garantizar diferenciación.',
 'easy',
 '["emprenedurismo"]'::jsonb),

 (4, 1,
 'Este tipo de emprendedor se mantiene atento a su entorno analizando las necesidades y aprovechándolas para desarrollar soluciones y obtener ganancias.',
 '[
   {"key": "a", "text": "Oportunista", "image": null},
   {"key": "b", "text": "Adquisitivo", "image": null},
   {"key": "c", "text": "Incubador", "image": null},
 ]'::jsonb,
 'a',
 'Oportunista: El emprendedor oportunista analiza su entorno en busca de la ocasión perfecta para poder aprovecharla. Desarrolla estrategias que puedan funcionar para atender las necesidades que surgen gracias a una tendencia y obtener ganancias de ello.',
 'easy',
 '[""]'::jsonb),


/* 

 (4, 1,
 '',
 '[
   {"key": "a", "text": "", "image": null},
   {"key": "b", "text": "", "image": null},
   {"key": "c", "text": "", "image": null},
 ]'::jsonb,
 'c',
 '',
 'easy',
 '[""]'::jsonb),

 */



 /* 

-- ─── PREGUNTAS: REDACCIÓN INDIRECTA - ORTOGRAFÍA (skill_id = 4) ────────────

INSERT INTO questions (skill_id, set_id, stem, options_json, correct_key, explanation, difficulty, tags_json) VALUES

(4, 1,
 '¿A qué tipo de organización corresponde una empresa que produce zapatos?',
 '[
   {"key": "a", "text": "Industrial", "image": null},
   {"key": "b", "text": "Comercial", "image": null},
   {"key": "c", "text": "De servicios", "image": null},
 ]'::jsonb,
 'a',
 'Las palabras graves terminadas en "n" no llevan tilde. Correcto: examen, imagen, volumen, origen.',
 'easy',
 '["ortografia", "acentuacion"]'::jsonb),

(4, 1,
 'Identifica la oración con error ortográfico:',
 '[
   {"key": "a", "text": "Él trajo el libro ayer", "image": null},
   {"key": "b", "text": "No sé si vendré mañana", "image": null},
   {"key": "c", "text": "Tu bien lo sabes", "image": null},
   {"key": "d", "text": "¿Dónde está mi mochila?", "image": null}
 ]'::jsonb,
 'c',
 'Debería ser "Tú bien lo sabes" (con tilde). "Tú" es pronombre personal, "tu" es posesivo.',
 'medium',
 '["ortografia", "tildes_diacriticas"]'::jsonb);

-- ─── PREGUNTAS: PENSAMIENTO MATEMÁTICO - ARITMÉTICA (skill_id = 7) ─────────

INSERT INTO questions (skill_id, set_id, stem, options_json, correct_key, explanation, difficulty, tags_json) VALUES

(7, 1,
 'Si x + 12 = 35, ¿cuánto vale x?',
 '[
   {"key": "a", "text": "23", "image": null},
   {"key": "b", "text": "47", "image": null},
   {"key": "c", "text": "12", "image": null},
   {"key": "d", "text": "35", "image": null}
 ]'::jsonb,
 'a',
 'Despejando: x = 35 - 12 = 23',
 'easy',
 '["aritmetica", "ecuaciones_basicas"]'::jsonb),

(7, 1,
 'Una tienda ofrece 25% de descuento en un artículo de $800. ¿Cuál es el precio final?',
 '[
   {"key": "a", "text": "$200", "image": null},
   {"key": "b", "text": "$600", "image": null},
   {"key": "c", "text": "$775", "image": null},
   {"key": "d", "text": "$625", "image": null}
 ]'::jsonb,
 'b',
 'Descuento = 800 × 0.25 = $200. Precio final = 800 - 200 = $600',
 'medium',
 '["aritmetica", "porcentajes"]'::jsonb),

(7, 1,
 'Si 3/4 de un número es 60, ¿cuál es el número?',
 '[
   {"key": "a", "text": "45", "image": null},
   {"key": "b", "text": "80", "image": null},
   {"key": "c", "text": "90", "image": null},
   {"key": "d", "text": "75", "image": null}
 ]'::jsonb,
 'b',
 '(3/4)x = 60. Entonces x = 60 × (4/3) = 80',
 'medium',
 '["aritmetica", "fracciones"]'::jsonb);

-- ─── PREGUNTAS: ÁLGEBRA (skill_id = 8) ──────────────────────────────────────

INSERT INTO questions (skill_id, set_id, stem, options_json, correct_key, explanation, difficulty, tags_json) VALUES

(8, 1,
 'Resuelve: 2x + 5 = 15',
 '[
   {"key": "a", "text": "x = 5", "image": null},
   {"key": "b", "text": "x = 10", "image": null},
   {"key": "c", "text": "x = 7.5", "image": null},
   {"key": "d", "text": "x = 20", "image": null}
 ]'::jsonb,
 'a',
 '2x = 15 - 5 = 10. Entonces x = 10/2 = 5',
 'easy',
 '["algebra", "ecuaciones_lineales"]'::jsonb),

(8, 1,
 'Factoriza: x² - 9',
 '[
   {"key": "a", "text": "(x - 3)(x - 3)", "image": null},
   {"key": "b", "text": "(x + 3)(x + 3)", "image": null},
   {"key": "c", "text": "(x - 9)(x + 1)", "image": null},
   {"key": "d", "text": "(x - 3)(x + 3)", "image": null}
 ]'::jsonb,
 'd',
 'Es una diferencia de cuadrados: a² - b² = (a - b)(a + b). Entonces x² - 9 = (x - 3)(x + 3)',
 'medium',
 '["algebra", "factorizacion"]'::jsonb);

-- ─── PREGUNTAS: GEOMETRÍA (skill_id = 9) ────────────────────────────────────

INSERT INTO questions (skill_id, set_id, stem, options_json, correct_key, explanation, difficulty, tags_json) VALUES

(9, 1,
 'El área de un rectángulo es 48 cm² y su base mide 8 cm. ¿Cuánto mide su altura?',
 '[
   {"key": "a", "text": "4 cm", "image": null},
   {"key": "b", "text": "6 cm", "image": null},
   {"key": "c", "text": "8 cm", "image": null},
   {"key": "d", "text": "12 cm", "image": null}
 ]'::jsonb,
 'b',
 'Área = base × altura. Entonces 48 = 8 × altura. altura = 48/8 = 6 cm',
 'easy',
 '["geometria", "areas"]'::jsonb),

(9, 1,
 'Un círculo tiene un radio de 7 cm. ¿Cuál es su área aproximada? (π ≈ 3.14)',
 '[
   {"key": "a", "text": "44 cm²", "image": null},
   {"key": "b", "text": "154 cm²", "image": null},
   {"key": "c", "text": "49 cm²", "image": null},
   {"key": "d", "text": "22 cm²", "image": null}
 ]'::jsonb,
 'b',
 'Área = πr² = 3.14 × 7² = 3.14 × 49 ≈ 154 cm²',
 'medium',
 '["geometria", "circulos"]'::jsonb);
 */
-- ═══════════════════════════════════════════════════════════════════════════════
-- RESUMEN:
-- - 2 preguntas de Comprensión Lectora (skill_id = 1)
-- - 2 preguntas de Ortografía (skill_id = 4)
-- - 3 preguntas de Aritmética (skill_id = 7)
-- - 2 preguntas de Álgebra (skill_id = 8)
-- - 2 preguntas de Geometría (skill_id = 9)
-- TOTAL: 11 preguntas ejemplo
--
-- Para completar las 168 preguntas necesarias para simulación:
-- 1. Replica esta estructura para cada skill_id (1-39)
-- 2. Distribuye preguntas según las áreas del examen
-- 3. Varía la dificultad (easy, medium, hard)
-- ═══════════════════════════════════════════════════════════════════════════════
