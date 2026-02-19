-- ═══════════════════════════════════════════════════════════════════════════════
-- Migration: Soporte para Múltiples Exámenes por Usuario
-- Fecha: 2026-02-19
-- Descripción: Permite a los usuarios preparar EXANI-I y EXANI-II simultáneamente
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─── 1. Agregar columna para examen activo ──────────────────────────────────
-- Permite cambiar entre exámenes sin perder datos de ambos
ALTER TABLE profiles 
ADD COLUMN active_exam_id BIGINT REFERENCES exams(id) ON DELETE SET NULL;

-- ─── 2. Migrar datos existentes ─────────────────────────────────────────────
-- Copiar exam_id actual a active_exam_id
UPDATE profiles 
SET active_exam_id = exam_id 
WHERE exam_id IS NOT NULL;

-- ─── 3. Convertir exam_id a array (exam_ids) ────────────────────────────────
-- Transform: exam_id (BIGINT) → exam_ids (JSONB array)
ALTER TABLE profiles 
ADD COLUMN exam_ids JSONB DEFAULT '[]'::jsonb;

-- Migrar exam_id existentes a exam_ids como array
UPDATE profiles 
SET exam_ids = jsonb_build_array(exam_id::text::int) 
WHERE exam_id IS NOT NULL;

-- ─── 4. Eliminar columna antigua ────────────────────────────────────────────
ALTER TABLE profiles 
DROP COLUMN exam_id;

-- ─── 5. Agregar constraint de validación ─────────────────────────────────────
-- Asegurar que active_exam_id está en exam_ids
ALTER TABLE profiles 
ADD CONSTRAINT check_active_exam_in_list 
CHECK (
  active_exam_id IS NULL 
  OR exam_ids @> to_jsonb(active_exam_id)
);

-- ─── 6. Crear índice para búsquedas eficientes ───────────────────────────────
CREATE INDEX idx_profiles_exam_ids ON profiles USING GIN (exam_ids);
CREATE INDEX idx_profiles_active_exam ON profiles(active_exam_id) WHERE active_exam_id IS NOT NULL;

-- ─── 7. Función helper: Agregar examen a usuario ─────────────────────────────
CREATE OR REPLACE FUNCTION add_exam_to_user(
  user_id_param UUID,
  exam_id_param BIGINT
)
RETURNS void AS $$
BEGIN
  -- Agregar exam_id a exam_ids si no existe
  UPDATE profiles
  SET exam_ids = exam_ids || to_jsonb(exam_id_param)
  WHERE id = user_id_param
    AND NOT (exam_ids @> to_jsonb(exam_id_param));
  
  -- Si no tiene active_exam_id, establecer este como activo
  UPDATE profiles
  SET active_exam_id = exam_id_param
  WHERE id = user_id_param
    AND active_exam_id IS NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── 8. Función helper: Remover examen de usuario ────────────────────────────
CREATE OR REPLACE FUNCTION remove_exam_from_user(
  user_id_param UUID,
  exam_id_param BIGINT
)
RETURNS void AS $$
DECLARE
  remaining_exams JSONB;
  first_exam_id BIGINT;
BEGIN
  -- Remover exam_id de exam_ids
  UPDATE profiles
  SET exam_ids = exam_ids - exam_id_param::text
  WHERE id = user_id_param;
  
  -- Si era el activo, cambiar a otro examen disponible
  SELECT exam_ids INTO remaining_exams
  FROM profiles
  WHERE id = user_id_param;
  
  IF jsonb_array_length(remaining_exams) > 0 THEN
    first_exam_id := (remaining_exams->0)::text::bigint;
    
    UPDATE profiles
    SET active_exam_id = first_exam_id
    WHERE id = user_id_param 
      AND active_exam_id = exam_id_param;
  ELSE
    -- No quedan exámenes
    UPDATE profiles
    SET active_exam_id = NULL
    WHERE id = user_id_param;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── 9. Función helper: Cambiar examen activo ─────────────────────────────────
CREATE OR REPLACE FUNCTION switch_active_exam(
  user_id_param UUID,
  exam_id_param BIGINT
)
RETURNS void AS $$
BEGIN
  -- Verificar que el examen está en la lista del usuario
  IF NOT EXISTS (
    SELECT 1 FROM profiles 
    WHERE id = user_id_param 
      AND exam_ids @> to_jsonb(exam_id_param)
  ) THEN
    RAISE EXCEPTION 'Exam % not found in user exams', exam_id_param;
  END IF;
  
  -- Cambiar examen activo
  UPDATE profiles
  SET active_exam_id = exam_id_param
  WHERE id = user_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ─── 10. Actualizar función de onboarding ─────────────────────────────────────
-- Modificar para usar el nuevo sistema
CREATE OR REPLACE FUNCTION save_onboarding_data(
  user_id_param UUID,
  exam_id_param BIGINT,
  exam_date_param DATE,
  modules_param JSONB
)
RETURNS void AS $$
BEGIN
  -- Agregar examen a la lista
  PERFORM add_exam_to_user(user_id_param, exam_id_param);
  
  -- Actualizar fecha y módulos
  UPDATE profiles
  SET 
    exam_date = exam_date_param,
    modules_json = modules_param,
    onboarding_done = true,
    updated_at = now()
  WHERE id = user_id_param;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ═══════════════════════════════════════════════════════════════════════════════
-- Rollback (por si necesitas revertir)
-- ═══════════════════════════════════════════════════════════════════════════════
-- ALTER TABLE profiles ADD COLUMN exam_id BIGINT REFERENCES exams(id);
-- UPDATE profiles SET exam_id = active_exam_id;
-- ALTER TABLE profiles DROP COLUMN exam_ids;
-- ALTER TABLE profiles DROP COLUMN active_exam_id;
-- DROP FUNCTION IF EXISTS add_exam_to_user;
-- DROP FUNCTION IF EXISTS remove_exam_from_user;
-- DROP FUNCTION IF EXISTS switch_active_exam;
