# 📥 Supabase Data Import Guide

Comprehensive guide for adding questions and other data to your Supabase database.

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Method 1: SQL Editor (Supabase Dashboard)](#method-1-sql-editor)
3. [Method 2: Dart Script (Recommended for Bulk)](#method-2-dart-script)
4. [Method 3: Using Supabase MCP Tools](#method-3-supabase-mcp-tools)
5. [Method 4: CSV Import](#method-4-csv-import)
6. [Validation & Testing](#validation--testing)

---

## 🚀 Quick Start

**You currently have:** 3 questions  
**You need for simulation:** 168 questions  
**Estimated time to add:** 2-4 hours (using bulk methods)

**Recommendation:** Use Method 2 (Dart script) or Method 1 (SQL) for fastest results.

---

## Method 1: SQL Editor (Supabase Dashboard)

### ✅ Best for:

- Small to medium batches (1-50 questions)
- Quick manual additions
- Testing individual questions

### How to Use:

1. **Open Supabase Dashboard:**

   ```
   https://app.supabase.com
   → Your project
   → SQL Editor
   → New Query
   ```

2. **Run the seed script:**
   - Copy content from `scripts/seed_questions.sql`
   - Paste into SQL Editor
   - Click "Run" or press Ctrl+Enter

3. **Add your own questions:**
   ```sql
   INSERT INTO questions (
     skill_id,
     set_id,
     stem,
     options_json,
     correct_key,
     explanation,
     difficulty
   ) VALUES (
     1,  -- skill_id (see SKILL_ID_REFERENCE.md)
     1,  -- set_id (EXANI-II v1.0)
     'Tu pregunta aquí...',
     '[
       {"key": "a", "text": "Opción A", "image": null},
       {"key": "b", "text": "Opción B", "image": null},
       {"key": "c", "text": "Opción C", "image": null}
     ]'::jsonb,
     'b',  -- correct_key
     'Explicación de la respuesta correcta',
     'medium'  -- difficulty: easy, medium, hard
   );
   ```

### 💡 Pro Tips:

- Use `INSERT INTO ... VALUES (...), (...), (...);` for batch inserts (up to 50 at a time)
- Always include `::jsonb` after JSON arrays/objects
- Check `scripts/SKILL_ID_REFERENCE.md` for skill_id mapping

---

## Method 2: Dart Script (Recommended)

### ✅ Best for:

- Bulk imports (50-1000 questions)
- Programmatic generation
- Maintaining question banks in code

### Setup:

1. **Configure credentials** in `scripts/import_questions.dart`:

   ```dart
   const supabaseUrl = 'https://your-project.supabase.co';
   const supabaseAnonKey = 'your-anon-key';
   ```

2. **Get credentials:**
   - Supabase Dashboard → Settings → API
   - Copy "Project URL" and "anon/public key"

3. **Run the script:**
   ```bash
   dart run scripts/import_questions.dart
   ```

### Customizing the Script:

**Add more questions:**

```dart
final questions = [
  {
    'skill_id': 7,
    'set_id': 1,
    'stem': 'Tu pregunta aquí...',
    'options_json': [
      {'key': 'a', 'text': 'Opción A', 'image': null},
      {'key': 'b', 'text': 'Opción B', 'image': null},
    ],
    'correct_key': 'a',
    'explanation': 'Explicación...',
    'difficulty': 'medium',
    'tags_json': ['algebra', 'ecuaciones'],
    'is_active': true,
  },
  // ... más preguntas
];
```

**Import from JSON file:**

```dart
import 'dart:convert';
import 'dart:io';

Future<void> importFromJsonFile(String filepath) async {
  final jsonString = await File(filepath).readAsString();
  final questions = jsonDecode(jsonString) as List;

  await supabase.from('questions').insert(questions);
  print('✓ ${questions.length} preguntas importadas');
}
```

---

## Method 3: Supabase MCP Tools

### ✅ Best for:

- VS Code integration
- Automated workflows
- One-off insertions

### Available from this workspace:

**Execute SQL directly:**

```
Use the mcp_supabase_execute_sql tool
```

**Example:**
Ask GitHub Copilot:

> "Use mcp_supabase_execute_sql to insert 5 questions about algebra (skill_id = 8)"

---

## Method 4: CSV Import

### ✅ Best for:

- Importing from spreadsheets
- Large datasets (100+ questions)
- Non-technical team members

### Steps:

1. **Create CSV file** (`questions.csv`):

   ```csv
   skill_id,set_id,stem,options_json,correct_key,explanation,difficulty
   1,1,"¿Pregunta 1?","[{""key"":""a"",""text"":""Opción A""}]","a","Explicación","easy"
   2,1,"¿Pregunta 2?","[{""key"":""b"",""text"":""Opción B""}]","b","Explicación","medium"
   ```

2. **Convert to SQL:**

   ```bash
   # Use online tool or custom script
   https://www.convertcsv.com/csv-to-sql.htm
   ```

3. **Run SQL in Supabase Dashboard**

### ⚠️ Important for JSON columns:

CSV imports require escaped quotes in JSON. It's easier to use Method 1 or 2 for questions.

---

## 🧪 Validation & Testing

### After importing, verify:

**1. Check question count:**

```sql
SELECT COUNT(*) FROM questions WHERE is_active = true;
```

**2. Check distribution by skill:**

```sql
SELECT
  sk.name AS skill,
  COUNT(q.id) AS num_questions
FROM skills sk
LEFT JOIN questions q ON sk.id = q.skill_id
WHERE sk.is_active = true
GROUP BY sk.id, sk.name
ORDER BY sk.id;
```

**3. Check distribution by difficulty:**

```sql
SELECT
  difficulty,
  COUNT(*) AS count
FROM questions
WHERE is_active = true
GROUP BY difficulty;
```

**4. Validate question format:**

```sql
SELECT
  id,
  stem,
  jsonb_array_length(options_json) AS num_options,
  correct_key
FROM questions
WHERE jsonb_array_length(options_json) < 3  -- Find questions with < 3 options
   OR correct_key IS NULL                   -- Or missing answer
   OR stem IS NULL;                         -- Or missing question text
```

### Test in the app:

1. **Run the app:**

   ```bash
   flutter run
   ```

2. **Start a practice session:**
   - Navigate to "Práctica"
   - Select a section/area/skill
   - Verify questions load correctly

3. **Check simulation mode:**
   - Navigate to "Simulacro"
   - Verify 168 questions load (requires full database)

---

## 📊 Recommended Import Strategy

For **168 questions** (full EXANI-II simulation):

### Phase 1: Foundation (50 questions) - 30 mins

Use **Method 1** (SQL Editor):

- 10 questions Comprensión lectora (skill_id 1-3)
- 10 questions Redacción (skill_id 4-6)
- 10 questions Matemáticas (skill_id 7-9)
- 10 questions Física (skill_id 10-12)
- 10 questions Química (skill_id 13-15)

→ Run `scripts/seed_questions.sql` (already has 11 example questions)

### Phase 2: Core Content (100 questions) - 1-2 hours

Use **Method 2** (Dart Script):

- Modify `scripts/import_questions.dart`
- Add 100 questions across all skills
- Run script: `dart run scripts/import_questions.dart`

### Phase 3: Completion (18 questions) - 20 mins

Use **Method 1** or **Method 2**:

- Fill gaps to reach 168 total
- Balance difficulty (40% easy, 40% medium, 20% hard)

---

## 🎯 Final Checklist

Before launching:

- [ ] Total questions in database: 168+
- [ ] All skills covered (1-24 for EXANI-II)
- [ ] Difficulty distribution balanced
- [ ] All questions have correct_key
- [ ] All questions have explanation
- [ ] options_json validated (3-4 options each)
- [ ] Tested in practice mode
- [ ] Tested in simulation mode (168 questions load)
- [ ] Images working (if any stem_image or explanation_images used)

---

## 🆘 Troubleshooting

**Error: "duplicate key value violates unique constraint"**

- You're trying to insert a question that already exists
- Solution: Check `id` values or let database auto-increment

**Error: "invalid input syntax for type json"**

- JSON formatting issue in `options_json`
- Solution: Use `::jsonb` cast and validate JSON syntax online

**Error: "foreign key constraint violation"**

- Invalid `skill_id` or `set_id`
- Solution: Check `scripts/SKILL_ID_REFERENCE.md` for valid IDs

**Questions not showing in app**

- Verify `is_active = true`
- Check RLS policies (should allow SELECT for authenticated users)
- Verify skill_id matches your navigation flow

---

## 📚 Next Steps

1. ✅ Import questions using one of the methods above
2. ✅ Validate data using SQL queries
3. ✅ Test in the app (practice and simulation modes)
4. ✅ Complete manual testing checklist (see `TEST_SUMMARY.md`)
5. 🚀 Launch to Play Store!

---

**Need help?** Check:

- `scripts/seed_questions.sql` - Example SQL inserts
- `scripts/import_questions.dart` - Example Dart script
- `scripts/SKILL_ID_REFERENCE.md` - Skill ID mapping
- `supabase/schema.sql` - Full database schema
