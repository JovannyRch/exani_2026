-- Fix: handle_new_user intentaba insertar columnas inexistentes (email, full_name)
-- La tabla profiles solo tiene: id, display_name, exam_id, exam_date, modules_json,
-- onboarding_done, created_at, updated_at, active_exam_id, exam_ids, role

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, role)
  VALUES (
    NEW.id,
    COALESCE(
      NEW.raw_user_meta_data->>'full_name',
      NEW.raw_user_meta_data->>'name',
      split_part(NEW.email, '@', 1)
    ),
    'author'
  );
  RETURN NEW;
END;
$$;
