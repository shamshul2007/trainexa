CREATE OR REPLACE FUNCTION insert_user_to_auth(
    email text,
    password text
) RETURNS UUID AS $$
DECLARE
  user_id uuid;
  encrypted_pw text;
BEGIN
  user_id := gen_random_uuid();
  encrypted_pw := crypt(password, gen_salt('bf'));
  
  INSERT INTO auth.users
    (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, recovery_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
  VALUES
    (gen_random_uuid(), user_id, 'authenticated', 'authenticated', email, encrypted_pw, '2023-05-03 19:41:43.585805+00', '2023-04-22 13:10:03.275387+00', '2023-04-22 13:10:31.458239+00', '{"provider":"email","providers":["email"]}', '{}', '2023-05-03 19:41:43.580424+00', '2023-05-03 19:41:43.585948+00', '', '', '', '');
  
  INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
  VALUES
    (gen_random_uuid(), user_id, format('{"sub":"%s","email":"%s"}', user_id::text, email)::jsonb, 'email', '2023-05-03 19:41:43.582456+00', '2023-05-03 19:41:43.582497+00', '2023-05-03 19:41:43.582497+00');
  
  RETURN user_id;
END;
$$ LANGUAGE plpgsql;


SELECT insert_user_to_auth('john.doe@example.com', 'password123');
SELECT insert_user_to_auth('jane.smith@example.com', 'securepass');
SELECT insert_user_to_auth('bob.johnson@example.com', 'mypassword');

INSERT INTO public.user_profiles (id, name, age, sex, weight_lbs, height_cm, experience_level, primary_goal, equipment_available, constraints, created_at)
SELECT
  (SELECT id FROM auth.users WHERE email = 'john.doe@example.com'),
  'John Doe',
  30,
  'male',
  180.5,
  175.0,
  'intermediate',
  'muscle',
  '["dumbbells", "barbell", "bench"]'::JSONB,
  'Knee pain on heavy squats',
  NOW() - INTERVAL '3 months'
WHERE NOT EXISTS (SELECT 1 FROM public.user_profiles WHERE id = (SELECT id FROM auth.users WHERE email = 'john.doe@example.com'));

INSERT INTO public.user_profiles (id, name, age, sex, weight_lbs, height_cm, experience_level, primary_goal, equipment_available, constraints, created_at)
SELECT
  (SELECT id FROM auth.users WHERE email = 'jane.smith@example.com'),
  'Jane Smith',
  25,
  'female',
  130.0,
  160.0,
  'beginner',
  'weight_loss',
  '["resistance bands", "yoga mat"]'::JSONB,
  '',
  NOW() - INTERVAL '2 months'
WHERE NOT EXISTS (SELECT 1 FROM public.user_profiles WHERE id = (SELECT id FROM auth.users WHERE email = 'jane.smith@example.com'));

INSERT INTO public.user_profiles (id, name, age, sex, weight_lbs, height_cm, experience_level, primary_goal, equipment_available, constraints, created_at)
SELECT
  (SELECT id FROM auth.users WHERE email = 'bob.johnson@example.com'),
  'Bob Johnson',
  40,
  'male',
  200.0,
  180.0,
  'advanced',
  'strength',
  '["full gym access"]'::JSONB,
  'Shoulder mobility issues',
  NOW() - INTERVAL '1 month'
WHERE NOT EXISTS (SELECT 1 FROM public.user_profiles WHERE id = (SELECT id FROM auth.users WHERE email = 'bob.johnson@example.com'));


INSERT INTO public.workout_plans (id, user_id, start_date, end_date, duration_weeks, training_split, workouts, generated_at, ai_model, created_at, updated_at)
SELECT
  gen_random_uuid(),
  (SELECT id FROM public.user_profiles WHERE name = 'John Doe'),
  '2024-01-01',
  '2024-01-28',
  4,
  'Push/Pull/Legs',
  '[
    {"day": "Monday", "name": "Push Day", "exercises": [{"name": "Bench Press", "sets": "3", "reps": "8-12"}, {"name": "Overhead Press", "sets": "3", "reps": "8-12"}]},
    {"day": "Tuesday", "name": "Pull Day", "exercises": [{"name": "Deadlift", "sets": "3", "reps": "5-8"}, {"name": "Pull-ups", "sets": "3", "reps": "AMRAP"}]},
    {"day": "Wednesday", "name": "Leg Day", "exercises": [{"name": "Squats", "sets": "3", "reps": "8-12"}, {"name": "Leg Press", "sets": "3", "reps": "10-15"}]}
  ]'::JSONB,
  NOW() - INTERVAL '3 months',
  'proxy',
  NOW() - INTERVAL '3 months',
  NOW() - INTERVAL '3 months'
WHERE EXISTS (SELECT 1 FROM public.user_profiles WHERE name = 'John Doe');

INSERT INTO public.workout_plans (id, user_id, start_date, end_date, duration_weeks, training_split, workouts, generated_at, ai_model, created_at, updated_at)
SELECT
  gen_random_uuid(),
  (SELECT id FROM public.user_profiles WHERE name = 'Jane Smith'),
  '2024-02-15',
  '2024-03-15',
  4,
  'Full Body',
  '[
    {"day": "Monday", "name": "Full Body A", "exercises": [{"name": "Goblet Squat", "sets": "3", "reps": "10-15"}, {"name": "Push-ups", "sets": "3", "reps": "AMRAP"}]},
    {"day": "Wednesday", "name": "Full Body B", "exercises": [{"name": "Lunges", "sets": "3", "reps": "10-15 per leg"}, {"name": "Dumbbell Row", "sets": "3", "reps": "10-15"}]}
  ]'::JSONB,
  NOW() - INTERVAL '2 months',
  'proxy',
  NOW() - INTERVAL '2 months',
  NOW() - INTERVAL '2 months'
WHERE EXISTS (SELECT 1 FROM public.user_profiles WHERE name = 'Jane Smith');

INSERT INTO public.workout_plans (id, user_id, start_date, end_date, duration_weeks, training_split, workouts, generated_at, ai_model, created_at, updated_at)
SELECT
  gen_random_uuid(),
  (SELECT id FROM public.user_profiles WHERE name = 'Bob Johnson'),
  '2024-03-01',
  '2024-04-26',
  8,
  'Upper/Lower',
  '[
    {"day": "Monday", "name": "Upper Body Strength", "exercises": [{"name": "Barbell Row", "sets": "4", "reps": "5"}, {"name": "Incline Press", "sets": "4", "reps": "5"}]},
    {"day": "Tuesday", "name": "Lower Body Strength", "exercises": [{"name": "Front Squat", "sets": "4", "reps": "5"}, {"name": "Romanian Deadlift", "sets": "4", "reps": "6"}]}
  ]'::JSONB,
  NOW() - INTERVAL '1 month',
  'proxy',
  NOW() - INTERVAL '1 month',
  NOW() - INTERVAL '1 month'
WHERE EXISTS (SELECT 1 FROM public.user_profiles WHERE name = 'Bob Johnson');


INSERT INTO public.workout_sessions (id, user_id, workout_id, date, duration_minutes, completed, sets_logged, total_volume_lbs, created_at, updated_at)
SELECT
  gen_random_uuid(),
  (SELECT id FROM public.user_profiles WHERE name = 'John Doe'),
  'Push Day',
  '2024-01-01',
  60,
  TRUE,
  '[
    {"exercise": "Bench Press", "sets": [{"reps": 10, "weight": 135}, {"reps": 10, "weight": 135}, {"reps": 8, "weight": 145}]},
    {"exercise": "Overhead Press", "sets": [{"reps": 10, "weight": 75}, {"reps": 10, "weight": 75}, {"reps": 8, "weight": 85}]}
  ]'::JSONB,
  (10*135*2 + 8*145 + 10*75*2 + 8*85),
  NOW() - INTERVAL '3 months' + INTERVAL '1 day',
  NOW() - INTERVAL '3 months' + INTERVAL '1 day'
WHERE EXISTS (SELECT 1 FROM public.user_profiles WHERE name = 'John Doe');

INSERT INTO public.workout_sessions (id, user_id, workout_id, date, duration_minutes, completed, sets_logged, total_volume_lbs, created_at, updated_at)
SELECT
  gen_random_uuid(),
  (SELECT id FROM public.user_profiles WHERE name = 'John Doe'),
  'Pull Day',
  '2024-01-02',
  70,
  TRUE,
  '[
    {"exercise": "Deadlift", "sets": [{"reps": 5, "weight": 225}, {"reps": 5, "weight": 225}, {"reps": 3, "weight": 245}]},
    {"exercise": "Pull-ups", "sets": [{"reps": 8, "weight": 0}, {"reps": 7, "weight": 0}, {"reps": 6, "weight": 0}]}
  ]'::JSONB,
  (5*225*2 + 3*245),
  NOW() - INTERVAL '3 months' + INTERVAL '2 days',
  NOW() - INTERVAL '3 months' + INTERVAL '2 days'
WHERE EXISTS (SELECT 1 FROM public.user_profiles WHERE name = 'John Doe');

INSERT INTO public.workout_sessions (id, user_id, workout_id, date, duration_minutes, completed, sets_logged, total_volume_lbs, created_at, updated_at)
SELECT
  gen_random_uuid(),
  (SELECT id FROM public.user_profiles WHERE name = 'Jane Smith'),
  'Full Body A',
  '2024-02-15',
  45,
  TRUE,
  '[
    {"exercise": "Goblet Squat", "sets": [{"reps": 15, "weight": 25}, {"reps": 15, "weight": 25}, {"reps": 12, "weight": 30}]},
    {"exercise": "Push-ups", "sets": [{"reps": 10, "weight": 0}, {"reps": 8, "weight": 0}, {"reps": 7, "weight": 0}]}
  ]'::JSONB,
  (15*25*2 + 12*30),
  NOW() - INTERVAL '2 months' + INTERVAL '1 day',
  NOW() - INTERVAL '2 months' + INTERVAL '1 day'
WHERE EXISTS (SELECT 1 FROM public.user_profiles WHERE name = 'Jane Smith');

INSERT INTO public.workout_sessions (id, user_id, workout_id, date, duration_minutes, completed, sets_logged, total_volume_lbs, created_at, updated_at)
SELECT
  gen_random_uuid(),
  (SELECT id FROM public.user_profiles WHERE name = 'Bob Johnson'),
  'Upper Body Strength',
  '2024-03-01',
  75,
  TRUE,
  '[
    {"exercise": "Barbell Row", "sets": [{"reps": 5, "weight": 185}, {"reps": 5, "weight": 185}, {"reps": 5, "weight": 195}, {"reps": 5, "weight": 195}]},
    {"exercise": "Incline Press", "sets": [{"reps": 5, "weight": 155}, {"reps": 5, "weight": 155}, {"reps": 5, "weight": 165}, {"reps": 5, "weight": 165}]}
  ]'::JSONB,
  (5*185*2 + 5*195*2 + 5*155*2 + 5*165*2),
  NOW() - INTERVAL '1 month' + INTERVAL '1 day',
  NOW() - INTERVAL '1 month' + INTERVAL '1 day'
WHERE EXISTS (SELECT 1 FROM public.user_profiles WHERE name = 'Bob Johnson');