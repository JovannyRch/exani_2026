# 🎯 Backoffice EXANI - Product Requirements Document

## 📋 Resumen Ejecutivo

**Producto:** Panel de administración web para gestión de contenido del EXANI  
**Objetivo:** Facilitar la creación, edición y gestión de preguntas, exámenes y contenido educativo sin necesidad de conocimientos técnicos  
**Usuarios:** Administradores de contenido, educadores, revisores de calidad  
**Tecnología sugerida:** Web app (Flutter Web / React Admin / Refine.dev) + Supabase Backend

---

## 🎯 Objetivos del Proyecto

### Problema a Resolver

Actualmente, agregar y gestionar preguntas requiere:

- ✗ Conocimientos de SQL
- ✗ Acceso directo a la base de datos
- ✗ Edición manual de archivos .sql
- ✗ Sin validación en tiempo real
- ✗ Sin preview del contenido
- ✗ Difícil identificar errores o gaps en el contenido

### Solución Propuesta

Un backoffice que permita:

- ✓ Gestión visual de todo el contenido
- ✓ Formularios intuitivos con validación
- ✓ Preview en tiempo real
- ✓ Importación/exportación masiva
- ✓ Análisis de cobertura y calidad
- ✓ Control de versiones y auditoría

---

## 👥 Usuarios y Roles

### 1. Super Admin

**Permisos completos:**

- Gestionar usuarios y roles
- Configurar exámenes y estructuras
- Acceder a todas las funciones
- Ver logs y auditoría completa

### 2. Gestor de Contenido (Content Manager)

**Permisos:**

- Crear, editar, eliminar preguntas
- Importar/exportar preguntas
- Gestionar imágenes y multimedia
- Ver estadísticas de contenido
- Publicar/despublicar contenido

### 3. Revisor de Calidad (QA Reviewer)

**Permisos:**

- Ver y comentar preguntas
- Aprobar/rechazar preguntas
- Reportar errores
- Ver estadísticas de calidad

### 4. Autor de Contenido (Content Author)

**Permisos:**

- Crear y editar sus propias preguntas
- Solicitar revisión
- Ver estadísticas de sus preguntas

---

## 🎨 Funcionalidades Principales

### 1️⃣ Dashboard Principal

#### Vista General (Home)

```
┌─────────────────────────────────────────────┐
│  📊 EXANI Backoffice                        │
├─────────────────────────────────────────────┤
│                                             │
│  📈 Estadísticas Generales                 │
│  ┌──────────┬──────────┬──────────┬────────┐
│  │ Total    │ Activas  │ Borradores│ Aprob. │
│  │ 168      │ 145      │ 15        │ 8      │
│  └──────────┴──────────┴──────────┴────────┘
│                                             │
│  🎯 Cobertura por Sección                  │
│  Comprensión lectora    ████████░░  80%     │
│  Redacción indirecta    ██████████ 100%     │
│  Pensamiento mat.       ███░░░░░░░  30%     │
│  Física                 █████░░░░░  50%     │
│  Química                ████░░░░░░  40%     │
│                                             │
│  ⚠️ Alertas                                 │
│  • Física: Faltan 12 preguntas             │
│  • 8 preguntas pendientes de aprobación    │
│  • 3 preguntas sin explicación             │
│                                             │
│  📅 Actividad Reciente                     │
│  • Juan creó 5 preguntas de Álgebra        │
│  • María aprobó pregunta #234              │
│  • Pedro importó 20 preguntas              │
└─────────────────────────────────────────────┘
```

**Métricas Clave:**

- Total de preguntas por estado (activas, borradores, archivadas)
- Cobertura por sección/área/skill (% completado vs. target)
- Distribución de dificultad (easy/medium/hard)
- Preguntas pendientes de revisión
- Actividad reciente del equipo
- Alertas de contenido faltante

---

### 2️⃣ Gestión de Preguntas

#### 2.1 Listado de Preguntas

```
┌─────────────────────────────────────────────────────────────────┐
│  Preguntas                                        [+ Nueva]     │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🔍 Buscar: [________________]  Filtros: [▼ Sección] [▼ Skill] │
│                                                                 │
│  ┌───┬──────────────────────┬─────────┬──────┬────────┬───────┐
│  │ID │ Pregunta             │ Sección │ Skill│ Dific. │ Estado│
│  ├───┼──────────────────────┼─────────┼──────┼────────┼───────┤
│  │234│ ¿Cuál es la idea...  │ Comp L. │ Idea │ Medium │ ✓ Pub.│
│  │235│ Factoriza: x² + 5x..│ Matemá. │ Álg. │ Easy   │ ⏱ Rev.│
│  │236│ El enlace entre Na..│ Química │ Enla.│ Hard   │ 📝 Borr│
│  └───┴──────────────────────┴─────────┴──────┴────────┴───────┘
│                                                                 │
│  Mostrando 1-20 de 168                        [◀] 1 [▶]       │
└─────────────────────────────────────────────────────────────────┘
```

**Funcionalidades:**

- Tabla paginada con todas las preguntas
- Búsqueda por texto (stem, opciones, explicación)
- Filtros múltiples:
  - Por examen (EXANI-I, EXANI-II)
  - Por sección
  - Por área
  - Por skill
  - Por dificultad
  - Por estado (activa, borrador, archivada, pendiente revisión)
  - Por autor
  - Por fecha de creación/modificación
- Ordenamiento por columnas
- Acciones rápidas:
  - Vista previa (modal)
  - Editar
  - Duplicar
  - Archivar/Activar
  - Eliminar (con confirmación)
- Acciones masivas:
  - Seleccionar múltiples
  - Cambiar estado en lote
  - Exportar seleccionadas
  - Eliminar en lote

#### 2.2 Crear/Editar Pregunta

```
┌─────────────────────────────────────────────────────────────┐
│  Nueva Pregunta                           [Guardar] [Cancel]│
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📍 Ubicación                                               │
│  Examen:    [▼ EXANI-II                                  ] │
│  Sección:   [▼ Comprensión lectora                       ] │
│  Área:      [▼ Comprensión lectora general               ] │
│  Skill:     [▼ Identificar idea principal                ] │
│                                                             │
│  ❓ Pregunta                                                │
│  Enunciado:                                                 │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ Lee el siguiente texto:                               │ │
│  │                                                       │ │
│  │ [Escribe o pega el texto aquí...]                    │ │
│  │                                                       │ │
│  └───────────────────────────────────────────────────────┘ │
│  📷 [+ Agregar imagen]                                      │
│                                                             │
│  ✅ Opciones de Respuesta                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ A. [Opción A aquí...]              📷 [+ Imagen]    │   │
│  │ B. [Opción B aquí...]              📷 [+ Imagen] ✓  │ ← Correcta
│  │ C. [Opción C aquí...]              📷 [+ Imagen]    │   │
│  │ D. [Opción D aquí...]         [− Eliminar opción]   │   │
│  └─────────────────────────────────────────────────────┘   │
│  [+ Agregar opción]                                         │
│                                                             │
│  💡 Explicación                                             │
│  ┌───────────────────────────────────────────────────────┐ │
│  │ La respuesta correcta es B porque...                 │ │
│  │                                                       │ │
│  └───────────────────────────────────────────────────────┘ │
│  📷 [+ Agregar imágenes]                                    │
│                                                             │
│  ⚙️ Metadatos                                               │
│  Dificultad:  ( ) Fácil  (•) Media  ( ) Difícil            │
│  Tags:        [algebra] [ecuaciones] [+]                    │
│  Fuente:      [Ceneval 2025                              ] │
│                                                             │
│  👁️ Preview                                                 │
│  ┌───────────────────────────────────────────────────────┐ │
│  │  [Vista previa como aparece en la app]               │ │
│  └───────────────────────────────────────────────────────┘ │
│                                                             │
│  [💾 Guardar como borrador] [✓ Publicar] [🚫 Cancelar]   │
└─────────────────────────────────────────────────────────────┘
```

**Validaciones en Tiempo Real:**

- ✓ Enunciado no vacío (mínimo 10 caracteres)
- ✓ Al menos 3 opciones (máximo 4)
- ✓ Exactamente 1 respuesta correcta seleccionada
- ✓ Explicación no vacía (mínimo 20 caracteres)
- ✓ Todas las opciones completas
- ✓ Imágenes en formato válido (jpg, png, webp)
- ✓ Tamaño de imágenes < 2MB

**Features:**

- Editor de texto enriquecido (markdown support)
- Drag & drop para imágenes
- Preview en tiempo real (lado derecho o modal)
- Autoguardado como borrador cada 30s
- Sugerencias de IA (opcional, fase 2)
- Detección de duplicados (búsqueda semántica)
- Historial de versiones

---

### 3️⃣ Gestión de Estructura

#### 3.1 Exámenes

```
┌──────────────────────────────────────────┐
│  Exámenes                    [+ Nuevo]   │
├──────────────────────────────────────────┤
│                                          │
│  📘 EXANI-II (Superior)                  │
│  └─ 168 preguntas objetivo               │
│  └─ 270 minutos duración                 │
│  └─ [✏️ Editar] [⚙️ Config] [📊 Stats]   │
│                                          │
│  📗 EXANI-I (Medio Superior)             │
│  └─ 160 preguntas objetivo               │
│  └─ 240 minutos duración                 │
│  └─ [✏️ Editar] [⚙️ Config] [📊 Stats]   │
└──────────────────────────────────────────┘
```

#### 3.2 Secciones, Áreas y Skills

Vista jerárquica expandible:

```
┌─────────────────────────────────────────────────────────┐
│  Estructura de Contenido - EXANI-II         [+ Agregar]│
├─────────────────────────────────────────────────────────┤
│                                                         │
│  📂 Comprensión Lectora (30 reactivos)                 │
│   ├─ 📁 Comp. lectora general                          │
│   │   ├─ 🎯 Identificar idea principal (10/10) ✓       │
│   │   ├─ 🎯 Hacer inferencias (10/10) ✓                │
│   │   └─ 🎯 Identificar propósito (5/10) ⚠️           │
│   └─ [✏️ Editar] [+ Agregar área]                      │
│                                                         │
│  📂 Redacción Indirecta (30 reactivos)                 │
│   ├─ 📁 Redacción general                              │
│   │   ├─ 🎯 Ortografía (10/10) ✓                       │
│   │   ├─ 🎯 Sintaxis (8/10) ⚠️                        │
│   │   └─ 🎯 Cohesión textual (12/10) ✓                │
│   └─ [✏️ Editar] [+ Agregar área]                      │
│                                                         │
│  📂 Pensamiento Matemático (30 reactivos)              │
│   ├─ 📁 Pensamiento matemático general                 │
│   │   ├─ 🎯 Aritmética (5/10) ⚠️                      │
│   │   ├─ 🎯 Álgebra (3/10) ⚠️                         │
│   │   └─ 🎯 Geometría (2/10) ⚠️                       │
│   └─ [✏️ Editar] [+ Agregar área]                      │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Funcionalidades:**

- CRUD completo de secciones, áreas y skills
- Drag & drop para reordenar
- Indicadores visuales de completitud
- Alertas de contenido faltante
- Configuración de pesos y prioridades

---

### 4️⃣ Importación/Exportación Masiva

#### 4.1 Importar Preguntas

```
┌─────────────────────────────────────────────────────┐
│  Importar Preguntas                                 │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Selecciona el formato:                             │
│  ( ) Excel (.xlsx)                                  │
│  (•) CSV (.csv)                                     │
│  ( ) JSON (.json)                                   │
│  ( ) SQL (.sql)                                     │
│                                                     │
│  📄 Arrastra el archivo aquí                        │
│  ┌─────────────────────────────────────────────┐   │
│  │                                             │   │
│  │         🗂️                                  │   │
│  │     Suelta el archivo                       │   │
│  │                                             │   │
│  └─────────────────────────────────────────────┘   │
│  o [Seleccionar archivo]                            │
│                                                     │
│  📥 [Descargar plantilla Excel]                     │
│  📥 [Descargar plantilla CSV]                       │
│                                                     │
│  ─────────────────────────────────────────────────  │
│  Después de cargar:                                 │
│                                                     │
│  ✅ 45 preguntas válidas                            │
│  ⚠️ 3 preguntas con advertencias                   │
│  ❌ 2 preguntas con errores                         │
│                                                     │
│  Ver detalles ▼                                     │
│  ┌─────────────────────────────────────────────┐   │
│  │ Fila 12: Falta respuesta correcta           │   │
│  │ Fila 23: Skill ID no existe                 │   │
│  │ Fila 34: Menos de 3 opciones                │   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  [❌ Cancelar] [⬇️ Importar 45 válidas]            │
└─────────────────────────────────────────────────────┘
```

**Formatos Soportados:**

- Excel (.xlsx) - Plantilla estructurada
- CSV (.csv) - Importación masiva
- JSON (.json) - API-friendly
- SQL (.sql) - Backup/restore

**Proceso de Importación:**

1. Upload del archivo
2. Validación automática
3. Preview de preguntas a importar
4. Resolución de conflictos
5. Importación con progreso en tiempo real
6. Reporte de resultados

#### 4.2 Exportar Preguntas

```
┌─────────────────────────────────────────────────────┐
│  Exportar Preguntas                                 │
├─────────────────────────────────────────────────────┤
│                                                     │
│  📊 Seleccionar contenido:                          │
│  [✓] Todas las preguntas                            │
│  [ ] Solo preguntas activas                         │
│  [ ] Solo de una sección: [▼ Seleccionar]          │
│  [ ] Mis preguntas solamente                        │
│                                                     │
│  📋 Formato de exportación:                         │
│  (•) Excel (.xlsx) - Incluye formato                │
│  ( ) CSV (.csv) - Solo datos                        │
│  ( ) JSON (.json) - API format                      │
│  ( ) SQL (.sql) - INSERT statements                 │
│  ( ) PDF (.pdf) - Imprimible                        │
│                                                     │
│  ⚙️ Opciones:                                       │
│  [✓] Incluir imágenes                               │
│  [✓] Incluir explicaciones                          │
│  [✓] Incluir metadatos (tags, dificultad)          │
│  [ ] Incluir estadísticas de uso                    │
│                                                     │
│  [🚫 Cancelar] [⬇️ Exportar (168 preguntas)]       │
└─────────────────────────────────────────────────────┘
```

---

### 5️⃣ Gestión de Multimedia

```
┌─────────────────────────────────────────────────────┐
│  Biblioteca de Medios                               │
├─────────────────────────────────────────────────────┤
│                                                     │
│  [⬆️ Subir archivos]  [📁 Nueva carpeta]           │
│                                                     │
│  📁 Categorías:                                     │
│  ├─ 📂 Matemáticas (45 archivos)                   │
│  ├─ 📂 Física (23 archivos)                        │
│  ├─ 📂 Química (34 archivos)                       │
│  └─ 📂 Comprensión lectora (12 archivos)           │
│                                                     │
│  Vista: [🔲 Grid] [ ☰ Lista]  Orden: [▼ Reciente] │
│                                                     │
│  ┌──────┬──────┬──────┬──────┬──────┐              │
│  │ 📷   │ 📷   │ 📷   │ 📷   │ 📷   │              │
│  │ img1 │ img2 │ img3 │ img4 │ img5 │              │
│  │ 250KB│ 180KB│ 420KB│ 95KB │ 310KB│              │
│  └──────┴──────┴──────┴──────┴──────┘              │
│                                                     │
│  Seleccionada: img3.png                             │
│  ├─ Tamaño: 420 KB                                  │
│  ├─ Dimensiones: 800x600                            │
│  ├─ Usado en: 3 preguntas                           │
│  └─ [✏️ Renombrar] [🗑️ Eliminar] [📋 Copiar URL]  │
└─────────────────────────────────────────────────────┘
```

**Funcionalidades:**

- Upload de imágenes (drag & drop)
- Organización por carpetas
- Optimización automática de imágenes
- CDN integration (Supabase Storage)
- Editor básico de imágenes (crop, resize)
- Búsqueda de imágenes
- Vista de uso (qué preguntas usan cada imagen)
- Detección de imágenes no utilizadas

---

### 6️⃣ Analíticas y Reportes

#### 6.1 Dashboard de Contenido

```
┌──────────────────────────────────────────────────────────┐
│  📊 Analíticas de Contenido                              │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  📈 Cobertura del Banco de Preguntas                     │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Target: 168    Actual: 145    Gap: 23 (-13.7%)   │ │
│  │  ████████████████████████████░░░░░░░░░  86.3%     │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  📊 Por Dificultad                                       │
│  ┌─────────┬─────────┬─────────┬─────────┐             │
│  │ Fácil   │ Media   │ Difícil │ Target  │             │
│  │ 58 (40%)│ 52 (36%)│ 35 (24%)│ 40/40/20│             │
│  └─────────┴─────────┴─────────┴─────────┘             │
│                                                          │
│  📋 Preguntas por Sección                                │
│  Comprensión lectora    ███████████ 30/30 ✓             │
│  Redacción indirecta    ███████████ 30/30 ✓             │
│  Pensamiento matemático ████░░░░░░ 12/30 ⚠️            │
│  Física                 ██████░░░░ 15/24 ⚠️            │
│  Química                █████░░░░░ 12/24 ⚠️            │
│  Inglés                 ███████████ 30/30 ✓             │
│                                                          │
│  👥 Productividad del Equipo (últimos 30 días)          │
│  ┌────────────┬──────────┬──────────┬────────┐         │
│  │ Usuario    │ Creadas  │ Editadas │ Aprob. │         │
│  ├────────────┼──────────┼──────────┼────────┤         │
│  │ Juan P.    │ 45       │ 12       │ 38     │         │
│  │ María G.   │ 32       │ 8        │ 29     │         │
│  │ Pedro R.   │ 28       │ 15       │ 24     │         │
│  └────────────┴──────────┴──────────┴────────┘         │
│                                                          │
│  📅 Timeline de Creación                                 │
│  [Gráfico de barras mostrando preguntas/semana]         │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

#### 6.2 Reportes de Calidad

```
┌──────────────────────────────────────────────────────────┐
│  🎯 Reporte de Calidad del Contenido                     │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ⚠️ Preguntas que Requieren Atención                    │
│                                                          │
│  ❌ Errores Críticos (2)                                 │
│  ├─ #234: Sin respuesta correcta marcada                │
│  └─ #456: Menos de 3 opciones                           │
│                                                          │
│  ⚠️ Advertencias (12)                                    │
│  ├─ #123: Explicación muy corta (<20 chars)             │
│  ├─ #234: Todas las opciones muy similares              │
│  ├─ #345: Sin tags asignados                            │
│  └─ [Ver todas...]                                       │
│                                                          │
│  💡 Sugerencias de Mejora (8)                            │
│  ├─ #567: Enunciado muy largo (>500 chars)              │
│  ├─ #678: Posible duplicado de #234                     │
│  └─ [Ver todas...]                                       │
│                                                          │
│  📊 Métricas de Calidad                                  │
│  ├─ Preguntas con explicación: 145/145 (100%) ✓         │
│  ├─ Preguntas con imágenes: 23/145 (15.9%)              │
│  ├─ Longitud promedio enunciado: 142 caracteres         │
│  ├─ Longitud promedio explicación: 89 caracteres        │
│  └─ Preguntas aprobadas: 138/145 (95.2%) ✓              │
│                                                          │
│  [📥 Exportar reporte] [🔄 Actualizar]                  │
└──────────────────────────────────────────────────────────┘
```

---

### 7️⃣ Workflow de Revisión y Aprobación

#### Estados de Pregunta:

1. **📝 Borrador** - Creada pero no lista
2. **⏱️ Pendiente de Revisión** - Esperando aprobación
3. **✅ Aprobada** - Lista para usar
4. **❌ Rechazada** - Requiere cambios
5. **📦 Archivada** - No se usa actualmente
6. **🚀 Publicada** - Activa en la app

#### Panel de Revisión

```
┌──────────────────────────────────────────────────────────┐
│  Pendientes de Revisión (8)                              │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  Pregunta #567 - por Juan P. (hace 2 días)              │
│  ┌────────────────────────────────────────────────────┐ │
│  │ ❓ Si x² + 3x - 10 = 0, ¿cuáles son las raíces?   │ │
│  │                                                    │ │
│  │ A. x = 2, x = -5  ✓                                │ │
│  │ B. x = -2, x = 5                                   │ │
│  │ C. x = 10, x = -3                                  │ │
│  │ D. x = 1, x = -10                                  │ │
│  │                                                    │ │
│  │ 💡 Factorizando: (x + 5)(x - 2) = 0               │ │
│  │    Entonces x = -5 o x = 2                         │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  📝 Comentarios:                                         │
│  ├─ María (reviewer): "Verificar que la explicación    │
│  │   mencione cómo se factoriza"                        │
│  └─ [Agregar comentario...]                             │
│                                                          │
│  ✏️ Solicitar cambios: [__________________________]     │
│                                                          │
│  [❌ Rechazar] [💬 Comentar] [✅ Aprobar]               │
│                                                          │
│  ────────────────────────────────────────────────────── │
│  [Pregunta anterior] [Siguiente pregunta]                │
└──────────────────────────────────────────────────────────┘
```

**Workflow:**

1. Autor crea pregunta → Estado: Borrador
2. Autor envía a revisión → Estado: Pendiente de Revisión
3. Reviewer aprueba/rechaza/comenta
4. Si rechaza → Autor recibe notificación con feedback
5. Autor corrige → Reenvía a revisión
6. Si aprueba → Estado: Aprobada
7. Admin publica → Estado: Publicada (visible en app)

---

### 8️⃣ Gestión de Usuarios

```
┌──────────────────────────────────────────────────────────┐
│  👥 Usuarios del Backoffice                  [+ Invitar] │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┬────────────┬──────────┬─────────────┐ │
│  │ Usuario      │ Rol        │ Preguntas│ Último acc. │ │
│  ├──────────────┼────────────┼──────────┼─────────────┤ │
│  │ Juan Pérez   │ Admin      │ 45       │ Hace 2h     │ │
│  │ María García │ Content Mgr│ 32       │ Hace 1 día  │ │
│  │ Pedro Ruiz   │ Author     │ 28       │ Hace 3 días │ │
│  │ Ana López    │ QA Reviewer│ 0        │ Hace 1h     │ │
│  └──────────────┴────────────┴──────────┴─────────────┘ │
│                                                          │
│  [Cada fila tiene: Editar | Cambiar rol | Suspender]    │
└──────────────────────────────────────────────────────────┘
```

---

## 🔧 Consideraciones Técnicas

### Stack Tecnológico Recomendado

#### Opción 1: Flutter Web (Recomendado)

**Pros:**

- ✓ Mismo código que la app móvil
- ✓ UI consistente
- ✓ Equipo ya conoce Flutter
- ✓ Integración nativa con Supabase

**Stack:**

```
Frontend: Flutter Web
Backend: Supabase (ya existente)
Storage: Supabase Storage
Auth: Supabase Auth
Database: PostgreSQL (ya existente)
Hosting: Vercel / Netlify / Firebase Hosting
```

#### Opción 2: React Admin

**Pros:**

- ✓ Ecosistema maduro para backoffices
- ✓ Muchos componentes pre-hechos
- ✓ Excelente documentación

**Stack:**

```
Frontend: React + React Admin / Refine.dev
Backend: Supabase (ya existente)
Hosting: Vercel / Netlify
```

### Arquitectura

```
┌─────────────────────────────────────────────────┐
│                                                 │
│           BACKOFFICE WEB APP                    │
│                                                 │
│  ┌─────────────┐  ┌──────────────┐            │
│  │ Auth Module │  │ Question CRUD│            │
│  └─────────────┘  └──────────────┘            │
│                                                 │
│  ┌──────────────┐  ┌──────────────┐           │
│  │ Media Library│  │ Analytics    │           │
│  └──────────────┘  └──────────────┘           │
│                                                 │
└────────────────┬────────────────────────────────┘
                 │
                 │ REST API / GraphQL
                 ▼
         ┌───────────────────┐
         │                   │
         │    SUPABASE       │
         │                   │
         │  ┌─────────────┐  │
         │  │ PostgreSQL  │  │
         │  └─────────────┘  │
         │  ┌─────────────┐  │
         │  │ Auth        │  │
         │  └─────────────┘  │
         │  ┌─────────────┐  │
         │  │ Storage     │  │
         │  └─────────────┘  │
         │  ┌─────────────┐  │
         │  │ Edge Fns    │  │
         │  └─────────────┘  │
         │                   │
         └───────────────────┘
```

### Base de Datos - Extensiones Necesarias

```sql
-- Nuevas tablas para el backoffice

-- Auditoría de cambios
CREATE TABLE audit_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  action TEXT NOT NULL,  -- 'create', 'update', 'delete', 'approve', etc.
  entity_type TEXT NOT NULL,  -- 'question', 'section', etc.
  entity_id BIGINT NOT NULL,
  changes_json JSONB,  -- Cambios realizados
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Comentarios en preguntas (workflow de revisión)
CREATE TABLE question_comments (
  id BIGSERIAL PRIMARY KEY,
  question_id BIGINT REFERENCES questions(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id),
  comment TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Estados de preguntas
ALTER TABLE questions ADD COLUMN status TEXT DEFAULT 'draft';
-- Valores: 'draft', 'pending_review', 'approved', 'rejected', 'archived', 'published'

-- Autor de la pregunta
ALTER TABLE questions ADD COLUMN author_id UUID REFERENCES auth.users(id);

-- Reviewer
ALTER TABLE questions ADD COLUMN reviewed_by UUID REFERENCES auth.users(id);
ALTER TABLE questions ADD COLUMN reviewed_at TIMESTAMPTZ;

-- Roles de usuarios (extender tabla profiles)
ALTER TABLE profiles ADD COLUMN role TEXT DEFAULT 'author';
-- Valores: 'super_admin', 'content_manager', 'qa_reviewer', 'author'
```

### Seguridad y Permisos (RLS Policies)

```sql
-- Solo usuarios autenticados con rol pueden acceder
CREATE POLICY "Backoffice users only"
  ON questions
  FOR ALL
  USING (
    auth.jwt() ->> 'role' IN ('super_admin', 'content_manager', 'qa_reviewer', 'author')
  );

-- Autores solo pueden editar sus propias preguntas
CREATE POLICY "Authors can edit own questions"
  ON questions
  FOR UPDATE
  USING (author_id = auth.uid())
  WITH CHECK (author_id = auth.uid());

-- Content managers pueden editar todas
CREATE POLICY "Content managers can edit all"
  ON questions
  FOR ALL
  USING (auth.jwt() ->> 'role' IN ('super_admin', 'content_manager'));
```

---

## 📅 Roadmap de Implementación

### Fase 1: MVP (2-3 semanas)

**Objetivo:** Backoffice funcional básico

- [x] Autenticación de usuarios
- [x] Dashboard principal con métricas básicas
- [x] CRUD de preguntas (crear, editar, eliminar)
- [x] Listado con filtros básicos (sección, skill, dificultad)
- [x] Importación CSV básica
- [x] Exportación a Excel/CSV
- [x] Gestión básica de imágenes (upload a Supabase Storage)

**Entregables:**

- Admin puede crear preguntas visualmente
- Importar lotes de 50+ preguntas desde CSV
- Exportar banco completo

### Fase 2: Workflow y Calidad (2-3 semanas)

**Objetivo:** Proceso de revisión y control de calidad

- [ ] Sistema de roles y permisos
- [ ] Workflow de aprobación (borrador → revisión → aprobado)
- [ ] Comentarios en preguntas
- [ ] Dashboard de calidad (detección de errores)
- [ ] Auditoría completa (logs de cambios)
- [ ] Búsqueda avanzada y filtros

**Entregables:**

- Proceso de revisión peer-to-peer
- Reporte de calidad automático
- Historial completo de cambios

### Fase 3: Analíticas y Optimización (1-2 semanas)

**Objetivo:** Inteligencia sobre el contenido

- [ ] Analytics dashboard completo
- [ ] Reportes de cobertura por skill
- [ ] Detección de duplicados (búsqueda semántica)
- [ ] Sugerencias de contenido faltante
- [ ] Estadísticas de uso desde la app móvil
- [ ] A/B testing de preguntas

**Entregables:**

- Dashboard con insights accionables
- Alertas automáticas de gaps de contenido

### Fase 4: Features Avanzados (2-3 semanas)

**Objetivo:** Productividad y automatización

- [ ] Editor WYSIWYG avanzado (rich text)
- [ ] Generación de preguntas con IA (GPT-4)
- [ ] Biblioteca de templates
- [ ] Versionado de preguntas
- [ ] API pública para integraciones
- [ ] Mobile app del backoffice (Flutter)

**Entregables:**

- IA para acelerar creación de contenido
- API documentada para automatizaciones

---

## 🎯 Métricas de Éxito

### KPIs del Backoffice

**Productividad:**

- Tiempo promedio para crear una pregunta: < 3 minutos
- Preguntas creadas por usuario/semana: > 20
- Tasa de importación exitosa: > 95%

**Calidad:**

- % preguntas con errores: < 2%
- Tiempo promedio de revisión: < 24 horas
- % preguntas aprobadas en primer intento: > 80%

**Cobertura:**

- Cumplimiento de target por sección: 100%
- Distribución de dificultad: 40/40/20 (easy/medium/hard)
- Skills sin preguntas: 0

**Adopción:**

- Usuarios activos semanales: > 5
- % de preguntas creadas vía backoffice vs. SQL: > 90%
- Satisfacción del usuario (NPS): > 8/10

---

## 💰 Estimación de Costos

### Desarrollo

| Fase              | Tiempo           | Costo Estimado        |
| ----------------- | ---------------- | --------------------- |
| Fase 1: MVP       | 2-3 semanas      | $3,000 - $5,000       |
| Fase 2: Workflow  | 2-3 semanas      | $3,000 - $5,000       |
| Fase 3: Analytics | 1-2 semanas      | $1,500 - $3,000       |
| Fase 4: Avanzado  | 2-3 semanas      | $3,000 - $5,000       |
| **TOTAL**         | **7-11 semanas** | **$10,500 - $18,000** |

### Infraestructura

| Servicio                 | Costo Mensual   |
| ------------------------ | --------------- |
| Supabase (Pro Plan)      | $25/mes         |
| Hosting (Vercel/Netlify) | $0 - $20/mes    |
| Storage (Supabase)       | ~$5/mes         |
| **TOTAL**                | **~$30-50/mes** |

---

## 🚀 Siguientes Pasos

### Para Empezar

1. **Aprobar PRD:** Revisar y validar requerimientos
2. **Elegir Stack:** Flutter Web vs. React Admin
3. **Setup Inicial:**
   - Crear repositorio
   - Configurar CI/CD
   - Setup Supabase policies
4. **Desarrollo Fase 1:** Implementar MVP en 2-3 semanas
5. **Testing y Feedback:** Pruebas con usuarios reales
6. **Iteración:** Mejorar basado en feedback

### Prototipo Rápido (1 semana)

Para validar concepto antes de desarrollo completo:

- Usar herramienta low-code (Retool, Appsmith)
- Conectar directamente a Supabase
- Probar con equipo pequeño
- Decidir si continuar con desarrollo custom

---

## 📚 Referencias y Recursos

### Inspiración de UI

- [Refine.dev Examples](https://refine.dev/examples/)
- [React Admin Demo](https://marmelab.com/react-admin-demo/)
- [Directus](https://directus.io/) - Headless CMS

### Stack Sugerido

- [Flutter Admin Template](https://github.com/example/flutter-admin)
- [Supabase Flutter](https://supabase.com/docs/reference/dart/introduction)
- [Flutter Data Tables](https://pub.dev/packages/data_table_2)

### Herramientas Low-Code (Prototipado)

- [Retool](https://retool.com/) - Internal tools builder
- [Appsmith](https://www.appsmith.com/) - Open source alternative
- [Budibase](https://budibase.com/) - Self-hosted option

---

## ✅ Checklist de Decisión

Antes de comenzar desarrollo, responder:

- [ ] ¿Cuántos usuarios usarán el backoffice? (1-5, 5-20, 20+)
- [ ] ¿Qué tan rápido necesitamos el MVP? (1 semana, 1 mes, 3+ meses)
- [ ] ¿Presupuesto disponible? (<$5k, $5k-$15k, $15k+)
- [ ] ¿Preferencia de tecnología? (Flutter, React, Low-code)
- [ ] ¿Features must-have vs. nice-to-have para MVP?
- [ ] ¿Equipo disponible para desarrollo? (1 dev, 2-3 devs, team)

---

**Documento creado:** 2026-02-19  
**Versión:** 1.0  
**Autor:** Copilot  
**Estado:** Propuesta inicial para revisión
