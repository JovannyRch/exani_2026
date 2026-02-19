# 🎯 Quick Start: Adding Data to Supabase

## ✅ What You Now Have

### 📁 Scripts Created

1. **`scripts/seed_questions.sql`** - SQL template with 11 example questions
2. **`scripts/import_questions.dart`** - Dart script for programmatic import
3. **`scripts/SKILL_ID_REFERENCE.md`** - Quick reference for skill IDs
4. **`scripts/DATA_IMPORT_GUIDE.md`** - Comprehensive how-to guide

### 📊 Current Database Status

- **Total questions:** 8
- **Skills covered:** 8
- **Difficulty:** 4 easy • 4 medium • 0 hard
- **Needed for simulation:** 168 questions
- **Progress:** 4.8% (8/168)

---

## 🚀 Quick Actions

### Option A: Use SQL (Fastest for Small Batches)

1. Open Supabase: https://app.supabase.com
2. Go to **SQL Editor** → **New Query**
3. Copy from `scripts/seed_questions.sql`
4. Click **Run**

### Option B: Use Dart Script (Best for 50+ Questions)

1. Edit `scripts/import_questions.dart`:

   ```dart
   const supabaseUrl = 'YOUR_URL_HERE';
   const supabaseAnonKey = 'YOUR_KEY_HERE';
   ```

2. Run:
   ```bash
   dart run scripts/import_questions.dart
   ```

### Option C: Use MCP Tool (From VS Code)

**Just ask me:**

> "Add 10 algebra questions (skill_id 8) about quadratic equations"

---

## 📝 Question Template (Copy & Modify)

```sql
INSERT INTO questions (skill_id, set_id, stem, options_json, correct_key, explanation, difficulty, tags_json)
VALUES (
  7,  -- ← Change to your skill_id (see SKILL_ID_REFERENCE.md)
  1,
  'Your question here?',  -- ← Your question
  '[
    {"key": "a", "text": "Option A", "image": null},
    {"key": "b", "text": "Option B", "image": null},
    {"key": "c", "text": "Option C", "image": null},
    {"key": "d", "text": "Option D", "image": null}
  ]'::jsonb,
  'c',  -- ← Correct answer key
  'Explanation here',  -- ← Why it's correct
  'medium',  -- ← easy, medium, or hard
  '["tag1", "tag2"]'::jsonb
);
```

---

## 🎓 Example Questions Added (Just Now)

I added 5 demonstration questions using the MCP tool:

1. **Inferencias** (skill 2) - María studying for exam → shows dedication
2. **Sintaxis** (skill 5) - Correct sentence structure
3. **Factorización** (skill 8) - Factor x² + 5x + 6
4. **Cinemática** (skill 10) - Calculate acceleration
5. **Enlaces químicos** (skill 14) - NaCl ionic bond

**You can verify in app:**

- Go to Práctica
- Select skill and these questions should appear

---

## 📊 Recommended Distribution

To reach 168 questions for full EXANI-II simulation:

| Section                | Questions Needed | Skills | Example Topics                          |
| ---------------------- | ---------------- | ------ | --------------------------------------- |
| Comprensión lectora    | 30               | 1-3    | Idea principal, inferencias, propósito  |
| Redacción indirecta    | 30               | 4-6    | Ortografía, sintaxis, cohesión          |
| Pensamiento matemático | 30               | 7-9    | Aritmética, álgebra, geometría          |
| Módulo 1 (Física)      | 24               | 10-12  | Mecánica, termodinámica, ondas          |
| Módulo 2 (Química)     | 24               | 13-15  | Estructura atómica, enlaces, reacciones |
| Inglés (diagnóstico)   | 30               | 22-24  | Reading, grammar, vocabulary            |
| **TOTAL**              | **168**          |        |                                         |

---

## ✅ Verification Query

Run this in Supabase SQL Editor to check your progress:

```sql
SELECT
  s.name AS section,
  sk.name AS skill,
  COUNT(q.id) AS num_questions
FROM skills sk
LEFT JOIN questions q ON sk.skill_id = q.skill_id AND q.is_active = true
JOIN areas a ON sk.area_id = a.id
JOIN sections s ON a.section_id = s.id
WHERE sk.is_active = true
GROUP BY s.id, s.name, sk.id, sk.name
ORDER BY s.id, sk.id;
```

---

## 🆘 Need Help?

**I can help you add questions!** Just ask:

- "Add 10 questions about algebra"
- "Add 5 easy questions about reading comprehension"
- "Add questions for skill_id 7 (arithmetic)"

**Or follow the guides:**

- 📖 Full guide: `scripts/DATA_IMPORT_GUIDE.md`
- 🔢 Skill IDs: `scripts/SKILL_ID_REFERENCE.md`
- 💾 SQL examples: `scripts/seed_questions.sql`
- 💻 Dart script: `scripts/import_questions.dart`

---

## 🎯 Next Steps

1. [ ] Choose your import method (SQL, Dart, or MCP)
2. [ ] Add questions batch by batch (aim for 20-30 per session)
3. [ ] Verify in app (test practice mode)
4. [ ] Continue until you have 168+ questions
5. [ ] Run simulation mode to verify all questions load
6. [ ] Complete manual testing checklist
7. [ ] 🚀 Launch to Play Store!

**Progress Goal:** Add ~20 questions per day for 8 days to reach 168 total

---

**Current Status:** 8/168 questions (4.8%) ✅  
**Time Estimate:** 2-4 hours total to reach 168 (using bulk methods)
