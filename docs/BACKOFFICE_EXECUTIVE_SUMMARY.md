# 🎯 Backoffice EXANI - Resumen Ejecutivo

## 📌 ¿Qué es?

Un **panel de administración web** para gestionar el contenido del examen EXANI sin necesidad de escribir SQL o código.

---

## ⚡ Problema que Resuelve

**Actualmente:**

- ❌ Agregar preguntas requiere SQL manual
- ❌ Alto riesgo de errores de sintaxis
- ❌ Difícil ver el progreso general
- ❌ No hay control de calidad visual
- ❌ Imposible para no-técnicos agregar contenido

**Con el Backoffice:**

- ✅ Formularios visuales intuitivos
- ✅ Validación en tiempo real
- ✅ Dashboard de progreso
- ✅ Workflow de revisión integrado
- ✅ Cualquiera puede agregar contenido

---

## 🎯 Usuarios Objetivo

1. **Administradores** - Gestión completa del sistema
2. **Gestores de Contenido** - Crear y aprobar preguntas
3. **Autores** - Crear preguntas para revisión
4. **Revisores QA** - Aprobar/rechazar preguntas

---

## 🚀 Funcionalidades Clave

### MVP (Fase 1 - 2-3 semanas)

| Funcionalidad          | Descripción                       | Impacto                       |
| ---------------------- | --------------------------------- | ----------------------------- |
| **Dashboard**          | Vista general con métricas        | Alta visibilidad del progreso |
| **CRUD Preguntas**     | Crear, editar, eliminar preguntas | Funcionalidad core            |
| **Búsqueda y Filtros** | Encontrar preguntas rápidamente   | Productividad                 |
| **Importar CSV/Excel** | Carga masiva de preguntas         | Acelera población inicial     |
| **Exportar**           | Backup del contenido              | Seguridad                     |
| **Upload Imágenes**    | Gestión de multimedia             | Contenido rico                |

### Fase 2 (2-3 semanas adicionales)

- Workflow de aprobación (borrador → revisión → publicado)
- Sistema de comentarios
- Auditoría completa
- Reportes de calidad

### Fase 3 (1-2 semanas adicionales)

- Analytics avanzados
- Detección de duplicados
- Alertas automáticas

---

## 💻 Stack Tecnológico

### Opción Recomendada: **Flutter Web**

**Por qué:**

- ✅ Mismo código que la app móvil (consistencia)
- ✅ Equipo ya conoce Flutter
- ✅ Desarrollo más rápido
- ✅ Puede compilar a desktop si se necesita

**Alternativa:** React + Refine.dev (si se prefiere ecosistema web puro)

**Backend:** Supabase (ya existente) - Sin cambios necesarios

---

## 📊 Mockups de Pantallas Principales

### 1. Dashboard

```
┌─────────────────────────────────────────┐
│ 📊 EXANI Backoffice                     │
├─────────────────────────────────────────┤
│ Total: 168 | Activas: 145 | Borr: 23   │
│                                         │
│ Cobertura por Sección:                  │
│ Comprensión lectora  ████████░░  80%   │
│ Matemáticas          ███░░░░░░░  30%   │
│                                         │
│ ⚠️ Alertas:                             │
│ • Faltan 12 preguntas de Física        │
│ • 8 pendientes de aprobación           │
└─────────────────────────────────────────┘
```

### 2. Listado de Preguntas

```
┌─────────────────────────────────────────┐
│ Preguntas                   [+ Nueva]   │
├─────────────────────────────────────────┤
│ 🔍 Buscar  | Filtros: [Sección] [Skill]│
│                                         │
│ #234 | ¿Cuál es...  | Comp.L | ✓ Pub. │
│ #235 | Factoriza... | Álgebra| ⏱ Rev. │
│ #236 | El enlace... | Química| 📝 Borr │
└─────────────────────────────────────────┘
```

### 3. Crear/Editar Pregunta

```
┌─────────────────────────────────────────┐
│ Nueva Pregunta          [Guardar][❌]   │
├─────────────────────────────────────────┤
│ Sección: [▼ Comprensión lectora]       │
│ Skill:   [▼ Identificar idea principal]│
│                                         │
│ Pregunta:                               │
│ [Escribe aquí...]                       │
│ [📷 Agregar imagen]                     │
│                                         │
│ Opciones:                               │
│ A. [Opción A] ○                         │
│ B. [Opción B] ● ← Correcta              │
│ C. [Opción C] ○                         │
│                                         │
│ Explicación:                            │
│ [Por qué es correcta...]                │
│                                         │
│ Dificultad: ( ) Fácil (•) Media ( ) Dif│
│                                         │
│ [💾 Borrador] [✓ Publicar]              │
└─────────────────────────────────────────┘
```

---

## 💰 Inversión Requerida

### Desarrollo

| Fase       | Duración         | Inversión             |
| ---------- | ---------------- | --------------------- |
| MVP (Core) | 2-3 semanas      | $3,000 - $5,000       |
| Workflow   | 2-3 semanas      | $3,000 - $5,000       |
| Analytics  | 1-2 semanas      | $1,500 - $3,000       |
| **TOTAL**  | **7-11 semanas** | **$10,500 - $18,000** |

### Operación Mensual

- Supabase Pro: $25/mes
- Hosting (Vercel): $0-20/mes
- **Total:** ~$30-50/mes

---

## ⏱️ Timeline

### Opción 1: Desarrollo Custom

```
Semana 1-3:  MVP funcionando
Semana 4-6:  Workflow de revisión
Semana 7-8:  Analytics y reportes
Semana 9+:   Features avanzados
```

### Opción 2: Prototipo Rápido (Validación)

```
Semana 1:    Prototipo con Retool/Appsmith
             (Low-code, conectado a Supabase)
             Costo: $29-99/mes

Después:     Decidir si desarrollar custom
             basado en feedback real
```

---

## ✅ Decisión: ¿Qué Hacer?

### Pregunta 1: ¿Cuándo necesitas esto?

- **Urgente (1-2 semanas):** → Prototipo low-code (Retool/Appsmith)
- **Normal (1-2 meses):** → Desarrollo MVP Flutter Web
- **Con calma (3+ meses):** → Desarrollo completo todas las fases

### Pregunta 2: ¿Cuántas personas lo usarán?

- **1-5 personas:** → Low-code suficiente
- **5-20 personas:** → Flutter Web MVP
- **20+ personas:** → Desarrollo completo custom

### Pregunta 3: ¿Presupuesto disponible?

- **< $500:** → Solo prototipo low-code
- **$3,000 - $5,000:** → MVP Flutter Web
- **$10,000+:** → Solución completa

---

## 🎯 Recomendación

### Para Arrancar Rápido (Esta Semana)

**Opción A: Prototipo con Retool** (Recomendada para validación)

1. **Día 1-2:** Setup Retool + conectar Supabase
2. **Día 3-4:** Crear interfaz básica CRUD preguntas
3. **Día 5:** Agregar importación CSV
4. **Resultado:** Panel funcional en 1 semana, $99/mes

**Ventajas:**

- ✅ Muy rápido (días vs semanas)
- ✅ Costo inicial bajo
- ✅ Valida la necesidad
- ✅ Después decides si desarrollar custom

### Para Solución Definitiva (1-2 Meses)

**Opción B: Desarrollo Flutter Web**

1. **Semana 1:** Setup + autenticación + dashboard
2. **Semana 2:** CRUD preguntas + filtros
3. **Semana 3:** Importación + imágenes
4. **Resultado:** MVP producción-ready en 3 semanas

**Ventajas:**

- ✅ Control total
- ✅ Personalización infinita
- ✅ Sin costos mensuales de plataforma
- ✅ Escalable a largo plazo

---

## 📚 Documentación Creada

| Documento                                                      | Qué Contiene                         | Para Quién       |
| -------------------------------------------------------------- | ------------------------------------ | ---------------- |
| [BACKOFFICE_PRD.md](BACKOFFICE_PRD.md)                         | Features, UI mockups, roles, roadmap | Product, negocio |
| [BACKOFFICE_TECHNICAL_SPECS.md](BACKOFFICE_TECHNICAL_SPECS.md) | Arquitectura, código, APIs           | Developers       |
| Este documento                                                 | Resumen ejecutivo, decisiones        | Stakeholders     |

---

## 🚦 Siguiente Paso

### Validar con el Equipo:

1. **¿Aprobar concepto general?**
   - [ ] Sí, necesitamos esto
   - [ ] No, seguimos con SQL manual
   - [ ] Tal vez, queremos ver prototipo primero

2. **¿Presupuesto disponible?**
   - [ ] < $500 (solo prototipo)
   - [ ] $3,000 - $5,000 (MVP)
   - [ ] $10,000+ (solución completa)

3. **¿Urgencia?**
   - [ ] Esta semana (prototipo low-code)
   - [ ] Este mes (MVP Flutter)
   - [ ] Puede esperar 2-3 meses (desarrollo completo)

4. **¿Quién lo usará?**
   - [ ] Solo yo (1 persona)
   - [ ] Equipo pequeño (2-5)
   - [ ] Equipo grande (5+)

---

## 📞 Próximos Pasos

**Si decides continuar:**

1. ✅ Aprobar este documento
2. ⚙️ Elegir opción (Retool vs Flutter Web)
3. 📝 Definir prioridades de features
4. 💻 Iniciar desarrollo o setup
5. 🧪 Testing con usuarios reales
6. 🚀 Launch interno

**Tiempo estimado hasta tener algo usable:**

- Prototipo: **5-7 días**
- MVP: **2-3 semanas**
- Completo: **7-11 semanas**

---

## 🎁 Bonus: Prototipo Gratis con Supabase Studio

**Mientras decides, puedes usar:**

Supabase tiene un **Table Editor** built-in que permite:

- ✅ Ver todas las preguntas
- ✅ Editar inline
- ✅ Agregar nuevas (aunque limitado)
- ✅ Filtrar y buscar

**Acceso:**

1. Ve a dashboard.supabase.com
2. Tu proyecto → Table Editor
3. Selecciona tabla `questions`

**Limitaciones:**

- No tiene validaciones avanzadas
- No tiene workflow de aprobación
- No tiene dashboard de métricas
- Pero sirve para necesidades muy básicas

---

**Documento Creado:** 2026-02-19  
**Versión:** 1.0  
**Estado:** Propuesta para decisión
