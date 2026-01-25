-- =====================================================
-- 001_schema.sql
-- CLEAN, IDEMPOTENT SCHEMA DEPLOYMENT (SUPABASE SAFE)
-- =====================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- STEP 1: Drop policies SAFELY (only if tables exist)
-- =====================================================

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='user_profiles') THEN
    DROP POLICY IF EXISTS "Users can view their own profile" ON public.user_profiles;
    DROP POLICY IF EXISTS "Users can insert their own profile" ON public.user_profiles;
    DROP POLICY IF EXISTS "Users can update their own profile" ON public.user_profiles;
    DROP POLICY IF EXISTS "Users can delete their own profile" ON public.user_profiles;
    DROP POLICY IF EXISTS "Service role can manage user_profiles" ON public.user_profiles;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='workout_plans') THEN
    DROP POLICY IF EXISTS "Users can view their own workout plans" ON public.workout_plans;
    DROP POLICY IF EXISTS "Users can insert their own workout plans" ON public.workout_plans;
    DROP POLICY IF EXISTS "Users can update their own workout plans" ON public.workout_plans;
    DROP POLICY IF EXISTS "Users can delete their own workout plans" ON public.workout_plans;
    DROP POLICY IF EXISTS "Service role can manage workout_plans" ON public.workout_plans;
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='workout_sessions') THEN
    DROP POLICY IF EXISTS "Users can view their own workout sessions" ON public.workout_sessions;
    DROP POLICY IF EXISTS "Users can insert their own workout sessions" ON public.workout_sessions;
    DROP POLICY IF EXISTS "Users can update their own workout sessions" ON public.workout_sessions;
    DROP POLICY IF EXISTS "Users can delete their own workout sessions" ON public.workout_sessions;
    DROP POLICY IF EXISTS "Service role can manage workout_sessions" ON public.workout_sessions;
  END IF;
END $$;

-- =====================================================
-- STEP 2: Drop tables
-- =====================================================

DROP TABLE IF EXISTS public.workout_sessions CASCADE;
DROP TABLE IF EXISTS public.workout_plans CASCADE;
DROP TABLE IF EXISTS public.user_profiles CASCADE;

-- =====================================================
-- STEP 3: Create tables
-- =====================================================

CREATE TABLE public.user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  age INTEGER NOT NULL,
  sex TEXT NOT NULL CHECK (sex IN ('male','female','other')),
  weight_lbs DOUBLE PRECISION NOT NULL,
  height_cm DOUBLE PRECISION NOT NULL,
  experience_level TEXT NOT NULL CHECK (experience_level IN ('beginner','intermediate','advanced')),
  primary_goal TEXT NOT NULL CHECK (primary_goal IN ('muscle','strength','endurance','weight_loss','toned','hybrid')),
  equipment_available JSONB NOT NULL DEFAULT '[]'::jsonb,
  constraints TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.workout_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  duration_weeks INTEGER NOT NULL,
  training_split TEXT NOT NULL,
  workouts JSONB NOT NULL,
  generated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  ai_model TEXT NOT NULL DEFAULT 'proxy',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE public.workout_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  workout_id TEXT NOT NULL,
  date DATE NOT NULL,
  duration_minutes INTEGER NOT NULL,
  completed BOOLEAN NOT NULL DEFAULT false,
  sets_logged JSONB NOT NULL,
  total_volume_lbs DOUBLE PRECISION NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- =====================================================
-- STEP 4: Indexes
-- =====================================================

CREATE INDEX ON public.workout_plans(user_id);
CREATE INDEX ON public.workout_plans(start_date);
CREATE INDEX ON public.workout_sessions(user_id);
CREATE INDEX ON public.workout_sessions(date);

-- =====================================================
-- STEP 5: RLS
-- =====================================================

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- STEP 6: Policies
-- =====================================================

-- user_profiles
CREATE POLICY "Users can view their own profile"
ON public.user_profiles FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
ON public.user_profiles FOR INSERT
WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
ON public.user_profiles FOR UPDATE
USING (auth.uid() = id);

CREATE POLICY "Users can delete their own profile"
ON public.user_profiles FOR DELETE
USING (auth.uid() = id);

CREATE POLICY "Service role can manage user_profiles"
ON public.user_profiles
FOR ALL
USING (auth.role() = 'service_role')
WITH CHECK (auth.role() = 'service_role');

-- workout_plans
CREATE POLICY "Users can view their own workout plans"
ON public.workout_plans FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own workout plans"
ON public.workout_plans FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own workout plans"
ON public.workout_plans FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own workout plans"
ON public.workout_plans FOR DELETE
USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage workout_plans"
ON public.workout_plans
FOR ALL
USING (auth.role() = 'service_role')
WITH CHECK (auth.role() = 'service_role');

-- workout_sessions
CREATE POLICY "Users can view their own workout sessions"
ON public.workout_sessions FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own workout sessions"
ON public.workout_sessions FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own workout sessions"
ON public.workout_sessions FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own workout sessions"
ON public.workout_sessions FOR DELETE
USING (auth.uid() = user_id);

CREATE POLICY "Service role can manage workout_sessions"
ON public.workout_sessions
FOR ALL
USING (auth.role() = 'service_role')
WITH CHECK (auth.role() = 'service_role');
