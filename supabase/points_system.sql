-- ═══════════════════════════════════════════════════════════════════════════════
-- EXANI Prep — Sistema de Puntos para Ranking
-- Versión: 1.0
-- Fecha: 2026-02-24
--
-- Este script agrega un sistema de puntos para gamificar el ranking semanal.
-- Los usuarios ganan puntos completando quizzes rápidos y simulacros.
--
-- EJECUTAR DESPUÉS DE: schema.sql, rls.sql, leaderboard.sql
-- ═══════════════════════════════════════════════════════════════════════════════

-- ─── 1. AGREGAR COLUMNA DE PUNTOS A SESSIONS ────────────────────────────────

ALTER TABLE sessions 
ADD COLUMN IF NOT EXISTS points_earned INT DEFAULT 0;

COMMENT ON COLUMN sessions.points_earned IS 
'Puntos ganados en esta sesión según fórmula: base_points × accuracy × speed_bonus';


-- ─── 2. AGREGAR COLUMNA DE PUNTOS A LEADERBOARD ─────────────────────────────

ALTER TABLE leaderboards_weekly 
ADD COLUMN IF NOT EXISTS total_points INT DEFAULT 0;

COMMENT ON COLUMN leaderboards_weekly.total_points IS 
'Suma total de puntos ganados por el usuario en la semana';


-- ─── 3. FUNCIÓN: Calcular puntos de una sesión ──────────────────────────────

CREATE OR REPLACE FUNCTION calculate_session_points(
  p_session_id BIGINT
)
RETURNS INT AS $$
DECLARE
  v_num_questions INT;
  v_correct_answers INT;
  v_avg_time_sec DECIMAL;
  v_accuracy DECIMAL;
  v_base_points DECIMAL;
  v_speed_bonus DECIMAL;
  v_total_points INT;
BEGIN
  -- Obtener datos de la sesión
  SELECT 
    s.total_questions,
    s.correct_answers,
    CASE 
      WHEN s.total_questions > 0 THEN s.total_time_ms / 1000.0 / s.total_questions
      ELSE 0
    END,
    CASE 
      WHEN s.total_questions > 0 THEN (s.correct_answers::DECIMAL / s.total_questions) * 100
      ELSE 0
    END
  INTO v_num_questions, v_correct_answers, v_avg_time_sec, v_accuracy
  FROM sessions s
  WHERE s.id = p_session_id;

  -- Si no hay datos, retornar 0
  IF v_num_questions IS NULL OR v_num_questions = 0 THEN
    RETURN 0;
  END IF;

  -- Calcular puntos base: numQuestions × 10 × (accuracy/100)
  v_base_points := v_num_questions * 10 * (v_accuracy / 100.0);

  -- Calcular bonus de velocidad
  v_speed_bonus := CASE
    WHEN v_avg_time_sec < 30 THEN v_base_points * 0.20  -- +20%
    WHEN v_avg_time_sec < 45 THEN v_base_points * 0.10  -- +10%
    WHEN v_avg_time_sec < 60 THEN v_base_points * 0.05  -- +5%
    ELSE 0
  END;

  -- Total de puntos
  v_total_points := ROUND(v_base_points + v_speed_bonus)::INT;

  -- Actualizar la sesión con los puntos ganados
  UPDATE sessions
  SET points_earned = v_total_points
  WHERE id = p_session_id;

  RETURN v_total_points;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION calculate_session_points IS 
'Calcula y asigna puntos a una sesión basándose en: preguntas contestadas, accuracy y velocidad';


-- ─── 4. ACTUALIZAR FUNCIÓN DE LEADERBOARD PARA INCLUIR PUNTOS ───────────────

CREATE OR REPLACE FUNCTION compute_weekly_leaderboard(
  p_week_start DATE DEFAULT date_trunc('week', CURRENT_DATE)::DATE
)
RETURNS void AS $$
DECLARE
  v_week_end DATE := p_week_start + INTERVAL '7 days';
BEGIN

  -- Borrar datos previos de esta semana (idempotente)
  DELETE FROM leaderboards_weekly WHERE week_start = p_week_start;

  -- Insertar rankings calculados
  INSERT INTO leaderboards_weekly (
    exam_id, week_start, user_id,
    score, accuracy_pct, avg_time_ms,
    total_questions, sessions_count, total_points
  )
  SELECT
    s.exam_id,
    p_week_start,
    s.user_id,

    -- ── Score compuesto (para mantener compatibilidad) ──
    ROUND(
      (accuracy_raw * 0.65) +
      (speed_score * 0.20) +
      (consistency_score * 0.15)
    , 2) AS score,

    ROUND(accuracy_raw, 2) AS accuracy_pct,
    avg_time_ms_clean::INT,
    total_valid_questions::INT,
    session_count::INT,
    
    -- ── Total de puntos ganados ──
    total_points::INT

  FROM (
    SELECT
      s.exam_id,
      s.user_id,

      -- Precisión: correctas / total × 100
      CASE
        WHEN COUNT(sq.id) FILTER (WHERE sq.time_ms >= 500) = 0 THEN 0
        ELSE (
          COUNT(sq.id) FILTER (WHERE sq.is_correct AND sq.time_ms >= 500)::DECIMAL
          / COUNT(sq.id) FILTER (WHERE sq.time_ms >= 500)
          * 100
        )
      END AS accuracy_raw,

      -- Tiempo promedio (ms) con cap de 300s y filtro de respuestas instantáneas
      COALESCE(
        AVG(LEAST(sq.time_ms, 300000)) FILTER (WHERE sq.time_ms >= 500),
        0
      ) AS avg_time_ms_clean,

      -- Speed score: 100 - (avg_seconds - 30) × 0.5, clamped [0, 100]
      GREATEST(0, LEAST(100,
        100 - (
          (COALESCE(AVG(LEAST(sq.time_ms, 300000)) FILTER (WHERE sq.time_ms >= 500), 0) / 1000.0 - 30)
          * 0.5
        )
      )) AS speed_score,

      -- Sesiones completadas en la semana
      COUNT(DISTINCT s.id) AS session_count,

      -- Consistency: min(sessions × 15, 100)
      LEAST(COUNT(DISTINCT s.id) * 15, 100) AS consistency_score,

      -- Total preguntas válidas (≥ 500ms para evitar spam)
      COUNT(sq.id) FILTER (WHERE sq.time_ms >= 500) AS total_valid_questions,
      
      -- Total puntos: subconsulta separada para evitar multiplicación
      (
        SELECT COALESCE(SUM(sess.points_earned), 0)
        FROM sessions sess
        WHERE sess.user_id = s.user_id
          AND sess.exam_id = s.exam_id
          AND sess.is_completed = true
          AND sess.created_at >= p_week_start
          AND sess.created_at < v_week_end
      ) AS total_points

    FROM sessions s
    JOIN session_questions sq ON sq.session_id = s.id
    WHERE s.is_completed = true
      AND s.created_at >= p_week_start
      AND s.created_at < v_week_end
      AND sq.chosen_key IS NOT NULL  -- solo respondidas
    GROUP BY s.exam_id, s.user_id
  ) AS s

  -- Ordenar por puntos (nuevo criterio principal), luego por score
  ORDER BY total_points DESC, score DESC;

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ─── 5. ACTUALIZAR FUNCIÓN GET_WEEKLY_LEADERBOARD ───────────────────────────

CREATE OR REPLACE FUNCTION get_weekly_leaderboard(
  p_exam_id BIGINT,
  p_week_start DATE DEFAULT date_trunc('week', CURRENT_DATE)::DATE,
  p_limit INT DEFAULT 50
)
RETURNS TABLE (
  rank        BIGINT,
  user_id     UUID,
  display_name TEXT,
  score       DECIMAL(8,2),
  accuracy_pct DECIMAL(5,2),
  avg_time_ms INT,
  total_questions INT,
  sessions_count INT,
  total_points INT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    ROW_NUMBER() OVER (ORDER BY lb.total_points DESC, lb.score DESC) AS rank,
    lb.user_id,
    COALESCE(p.display_name, 'Anónimo') AS display_name,
    lb.score,
    lb.accuracy_pct,
    lb.avg_time_ms,
    lb.total_questions,
    lb.sessions_count,
    lb.total_points
  FROM leaderboards_weekly lb
  LEFT JOIN profiles p ON p.id = lb.user_id
  WHERE lb.exam_id = p_exam_id
    AND lb.week_start = p_week_start
  ORDER BY lb.total_points DESC, lb.score DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ─── 6. ACTUALIZAR FUNCIÓN GET_MY_LEADERBOARD_POSITION ──────────────────────

CREATE OR REPLACE FUNCTION get_my_leaderboard_position(
  p_user_id UUID,
  p_exam_id BIGINT,
  p_week_start DATE DEFAULT date_trunc('week', CURRENT_DATE)::DATE
)
RETURNS TABLE (
  rank             BIGINT,
  score            DECIMAL(8,2),
  accuracy_pct     DECIMAL(5,2),
  total_questions  INT,
  sessions_count   INT,
  total_participants INT,
  total_points     INT
) AS $$
BEGIN
  RETURN QUERY
  WITH ranked AS (
    SELECT
      lb.user_id,
      ROW_NUMBER() OVER (ORDER BY lb.total_points DESC, lb.score DESC) AS rank,
      lb.score,
      lb.accuracy_pct,
      lb.total_questions,
      lb.sessions_count,
      lb.total_points
    FROM leaderboards_weekly lb
    WHERE lb.exam_id = p_exam_id
      AND lb.week_start = p_week_start
  )
  SELECT 
    r.rank, 
    r.score, 
    r.accuracy_pct, 
    r.total_questions,
    r.sessions_count,
    (SELECT COUNT(*) FROM ranked)::INT AS total_participants,
    r.total_points
  FROM ranked r
  WHERE r.user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ═══════════════════════════════════════════════════════════════════════════════
-- NOTAS DE USO
-- ═══════════════════════════════════════════════════════════════════════════════
--
-- 1. Al completar una sesión en la app, llamar:
--    SELECT calculate_session_points(<session_id>);
--
-- 2. Para recalcular leaderboard:
--    SELECT compute_weekly_leaderboard();
--
-- 3. Los puntos se actualizan automáticamente cuando se recalcula el leaderboard
--
-- ═══════════════════════════════════════════════════════════════════════════════
