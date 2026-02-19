# 🔧 Backoffice EXANI - Especificaciones Técnicas

## 📋 Tabla de Contenidos

1. [Arquitectura del Sistema](#arquitectura-del-sistema)
2. [Modelos de Datos](#modelos-de-datos)
3. [APIs y Endpoints](#apis-y-endpoints)
4. [Componentes UI](#componentes-ui)
5. [Flujos de Trabajo](#flujos-de-trabajo)
6. [Seguridad](#seguridad)
7. [Testing](#testing)
8. [Deployment](#deployment)

---

## 🏗️ Arquitectura del Sistema

### Diagrama de Alto Nivel

```
┌──────────────────────────────────────────────────────────┐
│                  USUARIOS                                │
│  Admin | Content Manager | QA Reviewer | Author          │
└────────────────────┬─────────────────────────────────────┘
                     │
                     │ HTTPS
                     ▼
┌──────────────────────────────────────────────────────────┐
│              BACKOFFICE WEB APP                          │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Presentation Layer (Flutter Web / React)          │ │
│  │  ┌──────────┬──────────┬──────────┬──────────┐    │ │
│  │  │Dashboard │Questions │Analytics │Settings   │    │ │
│  │  └──────────┴──────────┴──────────┴──────────┘    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Business Logic Layer                              │ │
│  │  ┌──────────┬──────────┬──────────┬──────────┐    │ │
│  │  │Auth Svc  │Question  │Media Svc │Analytics │    │ │
│  │  │          │Service   │          │Service   │    │ │
│  │  └──────────┴──────────┴──────────┴──────────┘    │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Data Access Layer                                 │ │
│  │  Supabase Client (REST / Realtime)                 │ │
│  └────────────────────────────────────────────────────┘ │
└────────────────────┬─────────────────────────────────────┘
                     │
                     │ REST / GraphQL / Realtime
                     ▼
┌──────────────────────────────────────────────────────────┐
│                 SUPABASE                                 │
│                                                          │
│  ┌───────────────┐  ┌───────────────┐  ┌────────────┐  │
│  │  PostgreSQL   │  │     Auth      │  │  Storage   │  │
│  │               │  │               │  │            │  │
│  │  • questions  │  │  • Users      │  │  • Images  │  │
│  │  • sections   │  │  • Roles      │  │  • Files   │  │
│  │  • skills     │  │  • Sessions   │  │            │  │
│  │  • audit_logs │  │               │  │            │  │
│  └───────────────┘  └───────────────┘  └────────────┘  │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │  Edge Functions (Serverless)                       │ │
│  │  • Image optimization                              │ │
│  │  • CSV import validation                           │ │
│  │  • Analytics aggregation                           │ │
│  │  • PDF generation                                  │ │
│  └────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
```

### Decisión: Flutter Web vs React

#### Opción A: Flutter Web (RECOMENDADA)

**Ventajas:**

- ✅ Mismo código base que la app móvil
- ✅ Equipo ya conoce Flutter/Dart
- ✅ Supabase SDK oficial para Dart
- ✅ Posibilidad de compilar a desktop (Windows/Mac/Linux)
- ✅ Hot reload para desarrollo rápido
- ✅ Type-safe con Dart

**Desventajas:**

- ⚠️ Tamaño inicial de carga mayor (~2MB)
- ⚠️ SEO limitado (no es problema para backoffice privado)
- ⚠️ Menos componentes UI pre-hechos para admin panels

**Stack:**

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.0.0
  go_router: ^13.0.0
  riverpod: ^2.4.0
  data_table_2: ^2.5.0
  file_picker: ^6.1.0
  image_picker_web: ^3.1.0
  excel: ^4.0.0
  csv: ^6.0.0
  fl_chart: ^0.66.0
  intl: ^0.19.0
```

#### Opción B: React + Refine.dev

**Ventajas:**

- ✅ Ecosistema maduro de admin panels
- ✅ Muchos componentes pre-hechos
- ✅ Excelente documentación
- ✅ Tamaño de bundle optimizado
- ✅ Más desarrolladores disponibles en el mercado

**Desventajas:**

- ⚠️ Equipo debe aprender React + TypeScript
- ⚠️ Código separado de la app móvil
- ⚠️ Más configuración inicial

**Stack:**

```json
{
  "dependencies": {
    "@refinedev/core": "^4.0.0",
    "@refinedev/supabase": "^5.0.0",
    "@supabase/supabase-js": "^2.38.0",
    "react": "^18.2.0",
    "react-router-dom": "^6.20.0",
    "antd": "^5.12.0",
    "recharts": "^2.10.0"
  }
}
```

**Recomendación:** Flutter Web por consistencia con el codebase existente.

---

## 📊 Modelos de Datos

### Extensiones a la Base de Datos

```sql
-- ══════════════════════════════════════════════════════════
-- BACKOFFICE DATABASE SCHEMA EXTENSIONS
-- ══════════════════════════════════════════════════════════

-- 1. Extender tabla de usuarios (profiles)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'author';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS department TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMPTZ;

-- Valores de role: 'super_admin', 'content_manager', 'qa_reviewer', 'author'

-- 2. Extender tabla de preguntas
ALTER TABLE questions ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'draft';
ALTER TABLE questions ADD COLUMN IF NOT EXISTS author_id UUID REFERENCES auth.users(id);
ALTER TABLE questions ADD COLUMN IF NOT EXISTS reviewed_by UUID REFERENCES auth.users(id);
ALTER TABLE questions ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMPTZ;
ALTER TABLE questions ADD COLUMN IF NOT EXISTS rejection_reason TEXT;
ALTER TABLE questions ADD COLUMN IF NOT EXISTS version INT DEFAULT 1;

-- Estados: 'draft', 'pending_review', 'approved', 'rejected', 'archived', 'published'

-- 3. Tabla de comentarios
CREATE TABLE IF NOT EXISTS question_comments (
  id BIGSERIAL PRIMARY KEY,
  question_id BIGINT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  comment TEXT NOT NULL,
  is_resolved BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_question_comments_question ON question_comments(question_id);
CREATE INDEX idx_question_comments_user ON question_comments(user_id);

-- 4. Tabla de auditoría
CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  action TEXT NOT NULL,  -- 'create', 'update', 'delete', 'approve', 'reject', 'publish'
  entity_type TEXT NOT NULL,  -- 'question', 'section', 'skill', 'user', etc.
  entity_id BIGINT NOT NULL,
  changes_json JSONB,  -- Snapshot de cambios
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at DESC);

-- 5. Tabla de versiones de preguntas
CREATE TABLE IF NOT EXISTS question_versions (
  id BIGSERIAL PRIMARY KEY,
  question_id BIGINT NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  version INT NOT NULL,
  snapshot_json JSONB NOT NULL,  -- Snapshot completo de la pregunta
  changed_by UUID REFERENCES auth.users(id),
  change_description TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),

  UNIQUE(question_id, version)
);

CREATE INDEX idx_question_versions_question ON question_versions(question_id);

-- 6. Tabla de importaciones
CREATE TABLE IF NOT EXISTS import_jobs (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  filename TEXT NOT NULL,
  file_format TEXT NOT NULL,  -- 'csv', 'excel', 'json', 'sql'
  total_rows INT DEFAULT 0,
  successful_rows INT DEFAULT 0,
  failed_rows INT DEFAULT 0,
  errors_json JSONB DEFAULT '[]'::jsonb,
  status TEXT DEFAULT 'processing',  -- 'processing', 'completed', 'failed'
  started_at TIMESTAMPTZ DEFAULT now(),
  completed_at TIMESTAMPTZ
);

CREATE INDEX idx_import_jobs_user ON import_jobs(user_id);
CREATE INDEX idx_import_jobs_status ON import_jobs(status);

-- 7. Tabla de media library
CREATE TABLE IF NOT EXISTS media_files (
  id BIGSERIAL PRIMARY KEY,
  filename TEXT NOT NULL,
  original_filename TEXT NOT NULL,
  file_path TEXT UNIQUE NOT NULL,  -- Ruta en Supabase Storage
  file_size BIGINT NOT NULL,  -- Bytes
  mime_type TEXT NOT NULL,
  width INT,
  height INT,
  category TEXT,  -- 'matematicas', 'fisica', etc.
  uploaded_by UUID REFERENCES auth.users(id),
  is_used BOOLEAN DEFAULT false,  -- Se actualiza automáticamente
  usage_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_media_files_category ON media_files(category);
CREATE INDEX idx_media_files_uploaded_by ON media_files(uploaded_by);

-- 8. Vista materializada: Estadísticas de preguntas
CREATE MATERIALIZED VIEW IF NOT EXISTS question_stats AS
SELECT
  s.id AS section_id,
  s.name AS section_name,
  sk.id AS skill_id,
  sk.name AS skill_name,
  COUNT(q.id) AS total_questions,
  COUNT(CASE WHEN q.status = 'published' THEN 1 END) AS published_questions,
  COUNT(CASE WHEN q.difficulty = 'easy' THEN 1 END) AS easy_questions,
  COUNT(CASE WHEN q.difficulty = 'medium' THEN 1 END) AS medium_questions,
  COUNT(CASE WHEN q.difficulty = 'hard' THEN 1 END) AS hard_questions,
  AVG(LENGTH(q.stem)) AS avg_stem_length,
  AVG(LENGTH(q.explanation)) AS avg_explanation_length
FROM sections s
LEFT JOIN areas a ON a.section_id = s.id
LEFT JOIN skills sk ON sk.area_id = a.id
LEFT JOIN questions q ON q.skill_id = sk.id AND q.is_active = true
WHERE s.is_active = true
GROUP BY s.id, s.name, sk.id, sk.name;

CREATE UNIQUE INDEX idx_question_stats_section_skill
  ON question_stats(section_id, skill_id);

-- Refresh periódico (ejecutar desde cron job o edge function cada hora)
-- REFRESH MATERIALIZED VIEW CONCURRENTLY question_stats;

-- 9. Función: Crear versión de pregunta automáticamente
CREATE OR REPLACE FUNCTION create_question_version()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    INSERT INTO question_versions (
      question_id,
      version,
      snapshot_json,
      changed_by,
      change_description
    ) VALUES (
      NEW.id,
      NEW.version,
      to_jsonb(OLD),
      NEW.updated_by,
      'Updated via backoffice'
    );

    NEW.version = OLD.version + 1;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER question_version_trigger
  BEFORE UPDATE ON questions
  FOR EACH ROW
  EXECUTE FUNCTION create_question_version();

-- 10. Función: Actualizar uso de imágenes
CREATE OR REPLACE FUNCTION update_media_usage()
RETURNS TRIGGER AS $$
BEGIN
  -- Actualizar usage_count basado en referencias en questions
  UPDATE media_files
  SET
    is_used = EXISTS (
      SELECT 1 FROM questions
      WHERE stem_image = media_files.file_path
         OR explanation_images_json @> to_jsonb(ARRAY[media_files.file_path])
    ),
    usage_count = (
      SELECT COUNT(*) FROM questions
      WHERE stem_image = media_files.file_path
         OR explanation_images_json @> to_jsonb(ARRAY[media_files.file_path])
    );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER media_usage_trigger
  AFTER INSERT OR UPDATE OR DELETE ON questions
  FOR EACH STATEMENT
  EXECUTE FUNCTION update_media_usage();
```

### Políticas RLS (Row Level Security)

```sql
-- ══════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY POLICIES
-- ══════════════════════════════════════════════════════════

-- Habilitar RLS en todas las tablas
ALTER TABLE question_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE question_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE import_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE media_files ENABLE ROW LEVEL SECURITY;

-- ─── Políticas para Questions ─────────────────────────────

-- SELECT: Todos los usuarios autenticados pueden ver preguntas
CREATE POLICY "Authenticated users can view questions"
  ON questions FOR SELECT
  TO authenticated
  USING (true);

-- INSERT: Solo authors, content_managers y admins pueden crear
CREATE POLICY "Authors can create questions"
  ON questions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid()
        AND role IN ('author', 'content_manager', 'super_admin')
        AND is_active = true
    )
  );

-- UPDATE: Authors pueden editar sus propias; managers/admins todas
CREATE POLICY "Authors can update own questions"
  ON questions FOR UPDATE
  TO authenticated
  USING (
    author_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid()
        AND role IN ('content_manager', 'super_admin')
        AND is_active = true
    )
  )
  WITH CHECK (
    author_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid()
        AND role IN ('content_manager', 'super_admin')
        AND is_active = true
    )
  );

-- DELETE: Solo admins pueden eliminar
CREATE POLICY "Only admins can delete questions"
  ON questions FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid()
        AND role = 'super_admin'
        AND is_active = true
    )
  );

-- ─── Políticas para Comments ──────────────────────────────

CREATE POLICY "Users can view all comments"
  ON question_comments FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can create comments"
  ON question_comments FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own comments"
  ON question_comments FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- ─── Políticas para Audit Logs ────────────────────────────

CREATE POLICY "Admins can view all audit logs"
  ON audit_logs FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid()
        AND role IN ('super_admin', 'content_manager')
    )
  );

-- ─── Políticas para Media Files ───────────────────────────

CREATE POLICY "Users can view all media"
  ON media_files FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can upload media"
  ON media_files FOR INSERT
  TO authenticated
  WITH CHECK (uploaded_by = auth.uid());

CREATE POLICY "Users can update own uploads"
  ON media_files FOR UPDATE
  TO authenticated
  USING (uploaded_by = auth.uid())
  WITH CHECK (uploaded_by = auth.uid());

CREATE POLICY "Admins can delete media"
  ON media_files FOR DELETE
  TO authenticated
  USING (
    uploaded_by = auth.uid()
    OR EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid()
        AND role IN ('super_admin', 'content_manager')
    )
  );
```

---

## 🔌 APIs y Endpoints

### Supabase Client - Operaciones Comunes

#### Autenticación

```dart
// Login
final response = await supabase.auth.signInWithPassword(
  email: email,
  password: password,
);

// Verificar rol
final user = supabase.auth.currentUser;
final role = user?.userMetadata?['role'] ?? 'author';

// Logout
await supabase.auth.signOut();
```

#### CRUD de Preguntas

```dart
// Listar preguntas con filtros
final response = await supabase
  .from('questions')
  .select('''
    *,
    skill:skills(id, name),
    author:profiles!author_id(id, display_name)
  ''')
  .eq('status', 'published')
  .order('created_at', ascending: false)
  .range(0, 19);  // Paginación

// Crear pregunta
final newQuestion = {
  'skill_id': 1,
  'set_id': 1,
  'stem': 'Pregunta...',
  'options_json': [...],
  'correct_key': 'b',
  'explanation': '...',
  'difficulty': 'medium',
  'status': 'draft',
  'author_id': supabase.auth.currentUser!.id,
};

final response = await supabase
  .from('questions')
  .insert(newQuestion)
  .select()
  .single();

// Actualizar pregunta
await supabase
  .from('questions')
  .update({
    'stem': 'Pregunta actualizada...',
    'updated_at': DateTime.now().toIso8601String(),
  })
  .eq('id', questionId);

// Cambiar estado
await supabase
  .from('questions')
  .update({
    'status': 'pending_review',
    'updated_at': DateTime.now().toIso8601String(),
  })
  .eq('id', questionId);

// Aprobar pregunta (solo reviewers)
await supabase
  .from('questions')
  .update({
    'status': 'approved',
    'reviewed_by': supabase.auth.currentUser!.id,
    'reviewed_at': DateTime.now().toIso8601String(),
  })
  .eq('id', questionId);

// Eliminar (soft delete)
await supabase
  .from('questions')
  .update({'is_active': false})
  .eq('id', questionId);
```

#### Búsqueda y Filtros

```dart
// Búsqueda por texto
final searchResults = await supabase
  .from('questions')
  .select()
  .textSearch('stem', query, config: 'spanish')
  .limit(20);

// Filtros combinados
final filtered = await supabase
  .from('questions')
  .select('''
    *,
    skill:skills(
      id, name,
      area:areas(
        id, name,
        section:sections(id, name)
      )
    )
  ''')
  .eq('difficulty', 'medium')
  .in_('status', ['draft', 'pending_review'])
  .gte('created_at', DateTime.now().subtract(Duration(days: 7)))
  .order('created_at', ascending: false);
```

#### Estadísticas

```dart
// Obtener estadísticas generales
final stats = await supabase
  .rpc('get_question_stats')
  .single();

// Función PostgreSQL correspondiente:
/*
CREATE OR REPLACE FUNCTION get_question_stats()
RETURNS JSON AS $$
  SELECT json_build_object(
    'total', COUNT(*),
    'published', COUNT(*) FILTER (WHERE status = 'published'),
    'draft', COUNT(*) FILTER (WHERE status = 'draft'),
    'pending_review', COUNT(*) FILTER (WHERE status = 'pending_review'),
    'by_difficulty', json_build_object(
      'easy', COUNT(*) FILTER (WHERE difficulty = 'easy'),
      'medium', COUNT(*) FILTER (WHERE difficulty = 'medium'),
      'hard', COUNT(*) FILTER (WHERE difficulty = 'hard')
    )
  )
  FROM questions
  WHERE is_active = true;
$$ LANGUAGE sql STABLE;
*/

// Cobertura por sección
final coverage = await supabase
  .from('question_stats')  // Materialized view
  .select('*')
  .order('section_id');
```

#### Upload de Imágenes

```dart
import 'package:file_picker/file_picker.dart';

// Seleccionar archivo
final result = await FilePicker.platform.pickFiles(
  type: FileType.image,
  allowMultiple: false,
);

if (result != null) {
  final file = result.files.first;
  final bytes = file.bytes!;

  // Upload a Supabase Storage
  final filename = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
  final path = 'questions/$filename';

  await supabase.storage
    .from('media')
    .uploadBinary(path, bytes, fileOptions: FileOptions(
      contentType: file.extension == 'png' ? 'image/png' : 'image/jpeg',
    ));

  // Obtener URL pública
  final publicUrl = supabase.storage
    .from('media')
    .getPublicUrl(path);

  // Registrar en media_files
  await supabase.from('media_files').insert({
    'filename': filename,
    'original_filename': file.name,
    'file_path': path,
    'file_size': bytes.length,
    'mime_type': 'image/${file.extension}',
    'uploaded_by': supabase.auth.currentUser!.id,
  });

  return publicUrl;
}
```

#### Importación CSV

```dart
import 'package:csv/csv.dart';

Future<void> importFromCSV(Uint8List fileBytes) async {
  // Parse CSV
  final csvString = utf8.decode(fileBytes);
  final rows = CsvToListConverter().convert(csvString);

  // Primera fila = headers
  final headers = rows.first.map((e) => e.toString()).toList();

  final questions = <Map<String, dynamic>>[];
  final errors = <String>[];

  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];

    try {
      // Validar y crear objeto
      final question = {
        'skill_id': int.parse(row[headers.indexOf('skill_id')].toString()),
        'set_id': int.parse(row[headers.indexOf('set_id')].toString()),
        'stem': row[headers.indexOf('stem')].toString(),
        'options_json': jsonDecode(row[headers.indexOf('options_json')].toString()),
        'correct_key': row[headers.indexOf('correct_key')].toString(),
        'explanation': row[headers.indexOf('explanation')].toString(),
        'difficulty': row[headers.indexOf('difficulty')].toString(),
        'status': 'draft',
        'author_id': supabase.auth.currentUser!.id,
      };

      // Validar
      if (question['stem'].toString().length < 10) {
        throw 'Enunciado muy corto';
      }

      questions.add(question);
    } catch (e) {
      errors.add('Fila ${i + 1}: $e');
    }
  }

  // Insertar en lote
  if (questions.isNotEmpty) {
    await supabase.from('questions').insert(questions);
  }

  // Registrar job
  await supabase.from('import_jobs').insert({
    'user_id': supabase.auth.currentUser!.id,
    'filename': 'import.csv',
    'file_format': 'csv',
    'total_rows': rows.length - 1,
    'successful_rows': questions.length,
    'failed_rows': errors.length,
    'errors_json': errors,
    'status': 'completed',
    'completed_at': DateTime.now().toIso8601String(),
  });

  return;
}
```

---

## 🎨 Componentes UI (Flutter)

### Estructura de Carpetas

```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── routes.dart
│   └── theme.dart
├── core/
│   ├── constants.dart
│   └── extensions.dart
├── models/
│   ├── question.dart
│   ├── user.dart
│   ├── comment.dart
│   └── stats.dart
├── providers/
│   ├── auth_provider.dart
│   ├── question_provider.dart
│   ├── stats_provider.dart
│   └── media_provider.dart
├── services/
│   ├── supabase_service.dart
│   ├── question_service.dart
│   ├── media_service.dart
│   └── export_service.dart
├── screens/
│   ├── auth/
│   │   └── login_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── questions/
│   │   ├── question_list_screen.dart
│   │   ├── question_edit_screen.dart
│   │   └── question_review_screen.dart
│   ├── analytics/
│   │   └── analytics_screen.dart
│   ├── media/
│   │   └── media_library_screen.dart
│   └── settings/
│       └── settings_screen.dart
└── widgets/
    ├── app_bar.dart
    ├── sidebar.dart
    ├── data_table.dart
    ├── question_card.dart
    ├── stats_card.dart
    └── file_uploader.dart
```

### Componentes Clave

#### 1. AppShell (Responsive Layout)

```dart
class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('EXANI Backoffice'),
        actions: [
          // Notificaciones
          IconButton(
            icon: Badge(
              label: Text('3'),
              child: Icon(Icons.notifications),
            ),
            onPressed: () {},
          ),
          // Usuario
          PopupMenuButton(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  CircleAvatar(
                    child: Text(user?.displayName?[0] ?? 'U'),
                  ),
                  SizedBox(width: 8),
                  Text(user?.displayName ?? 'Usuario'),
                ],
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Perfil'),
                value: 'profile',
              ),
              PopupMenuItem(
                child: Text('Configuración'),
                value: 'settings',
              ),
              PopupMenuDivider(),
              PopupMenuItem(
                child: Text('Cerrar sesión'),
                value: 'logout',
              ),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 800,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.question_answer),
                label: Text('Preguntas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics),
                label: Text('Analíticas'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.image),
                label: Text('Multimedia'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Configuración'),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              context.go(_routes[index]);
            },
          ),
          VerticalDivider(thickness: 1, width: 1),
          // Content
          Expanded(child: child),
        ],
      ),
    );
  }
}
```

#### 2. QuestionTable (Data Table)

```dart
import 'package:data_table_2/data_table_2.dart';

class QuestionTable extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(questionsProvider);

    return PaginatedDataTable2(
      columns: [
        DataColumn2(label: Text('ID'), size: ColumnSize.S),
        DataColumn2(label: Text('Pregunta'), size: ColumnSize.L),
        DataColumn2(label: Text('Sección')),
        DataColumn2(label: Text('Skill')),
        DataColumn2(label: Text('Dificultad'), size: ColumnSize.S),
        DataColumn2(label: Text('Estado'), size: ColumnSize.S),
        DataColumn2(label: Text('Acciones'), size: ColumnSize.M),
      ],
      source: QuestionDataSource(questions),
      rowsPerPage: 20,
      sortColumnIndex: 0,
      sortAscending: false,
    );
  }
}

class QuestionDataSource extends DataTableSource {
  final List<Question> questions;

  QuestionDataSource(this.questions);

  @override
  DataRow? getRow(int index) {
    final q = questions[index];

    return DataRow2(
      cells: [
        DataCell(Text('#${q.id}')),
        DataCell(
          Text(
            q.stem,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        DataCell(Text(q.skill.section.name)),
        DataCell(Text(q.skill.name)),
        DataCell(_DifficultyChip(q.difficulty)),
        DataCell(_StatusChip(q.status)),
        DataCell(
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit, size: 18),
                onPressed: () => _editQuestion(q),
              ),
              IconButton(
                icon: Icon(Icons.content_copy, size: 18),
                onPressed: () => _duplicateQuestion(q),
              ),
              IconButton(
                icon: Icon(Icons.delete, size: 18),
                onPressed: () => _deleteQuestion(q),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => questions.length;

  @override
  int get selectedRowCount => 0;
}
```

#### 3. QuestionEditor (Form)

```dart
class QuestionEditor extends ConsumerStatefulWidget {
  final Question? question;  // null = crear, non-null = editar

  @override
  ConsumerState<QuestionEditor> createState() => _QuestionEditorState();
}

class _QuestionEditorState extends ConsumerState<QuestionEditor> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _stemController;
  late List<OptionController> _optionControllers;
  late TextEditingController _explanationController;

  int? _selectedSkillId;
  String _selectedDifficulty = 'medium';
  String? _correctKey;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ubicación
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📍 Ubicación', style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 16),
                    SkillSelector(
                      selectedSkillId: _selectedSkillId,
                      onChanged: (skillId) {
                        setState(() => _selectedSkillId = skillId);
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Pregunta
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('❓ Pregunta', style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _stemController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Enunciado',
                        hintText: 'Escribe la pregunta aquí...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 10) {
                          return 'El enunciado debe tener al menos 10 caracteres';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8),
                    ImageUploader(
                      onImageUploaded: (url) {
                        // Guardar stem_image
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Opciones
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('✅ Opciones', style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 16),
                    ..._optionControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      final key = String.fromCharCode(97 + index); // a, b, c, d

                      return OptionField(
                        optionKey: key,
                        controller: controller,
                        isCorrect: _correctKey == key,
                        onCorrectChanged: (isCorrect) {
                          if (isCorrect) {
                            setState(() => _correctKey = key);
                          }
                        },
                        onRemove: _optionControllers.length > 3
                            ? () {
                                setState(() {
                                  _optionControllers.removeAt(index);
                                });
                              }
                            : null,
                      );
                    }),
                    if (_optionControllers.length < 4)
                      TextButton.icon(
                        icon: Icon(Icons.add),
                        label: Text('Agregar opción'),
                        onPressed: () {
                          setState(() {
                            _optionControllers.add(OptionController());
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Explicación
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡 Explicación', style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _explanationController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Explicación de la respuesta correcta',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 20) {
                          return 'La explicación debe tener al menos 20 caracteres';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Metadatos
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⚙️ Metadatos', style: Theme.of(context).textTheme.titleLarge),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text('Dificultad:'),
                        SizedBox(width: 16),
                        ChoiceChip(
                          label: Text('Fácil'),
                          selected: _selectedDifficulty == 'easy',
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedDifficulty = 'easy');
                          },
                        ),
                        SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('Media'),
                          selected: _selectedDifficulty == 'medium',
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedDifficulty = 'medium');
                          },
                        ),
                        SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('Difícil'),
                          selected: _selectedDifficulty == 'hard',
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedDifficulty = 'hard');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Acciones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel cancelar'),
                ),
                SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _saveDraft(),
                  child: Text('💾 Guardar borrador'),
                ),
                SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _publish(),
                  child: Text('✓ Publicar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveDraft() async {
    if (!_formKey.currentState!.validate()) return;

    // Guardar con status = 'draft'
    await ref.read(questionServiceProvider).saveQuestion(
      // ... datos
      status: 'draft',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Borrador guardado')),
    );
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_correctKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debes marcar la respuesta correcta')),
      );
      return;
    }

    // Guardar con status = 'pending_review'
    await ref.read(questionServiceProvider).saveQuestion(
      // ... datos
      status: 'pending_review',
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pregunta enviada a revisión')),
    );
  }
}
```

---

## 🔒 Seguridad

### Checklist de Seguridad

- [ ] **Autenticación:** Solo usuarios autorizados pueden acceder
  - Email/password required
  - 2FA opcional (fase 2)
  - Session timeout après 24h

- [ ] **Autorización:** Roles y permisos implementados
  - RLS policies en Supabase
  - Validación de permisos en frontend
  - Middleware para acciones sensibles

- [ ] **Validación de datos:**
  - Validación en frontend (UX)
  - Validación en backend (seguridad)
  - Sanitización de inputs
  - Protección contra SQL injection (Supabase maneja)

- [ ] **Protección de archivos:**
  - Solo formatos permitidos (jpg, png, webp)
  - Tamaño máximo 5MB
  - Escaneo antivirus (opcional, fase 2)
  - URLs firmadas para contenido sensible

- [ ] **Auditoría:**
  - Log de todas las acciones críticas
  - Retención de logs 90 días
  - IP y user agent registrados

- [ ] **Rate Limiting:**
  - Máximo 100 requests/minuto por usuario
  - Protección contra brute force
  - Implementado en Supabase Edge Functions

---

Esta es la **Parte 1** de las especificaciones técnicas. ¿Quieres que continúe con la Parte 2 que incluya Testing, Deployment, y Monitoreo?
