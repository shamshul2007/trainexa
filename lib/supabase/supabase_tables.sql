-- Trainexa Database Schema
-- Tables for user profiles, workout plans, and workout sessions

-- User Profiles table (linked to auth.users)
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  age INTEGER NOT NULL,
  sex TEXT NOT NULL CHECK (sex IN ('male', 'female', 'other')),
  weight_lbs DOUBLE PRECISION NOT NULL,
  height_cm DOUBLE PRECISION NOT NULL,
  experience_level TEXT NOT NULL CHECK (experience_level IN ('beginner', 'intermediate', 'advanced')),
  primary_goal TEXT NOT NULL CHECK (primary_goal IN ('muscle', 'strength', 'endurance', 'weight_loss', 'toned', 'hybrid')),
  equipment_available JSONB NOT NULL DEFAULT '[]'::JSONB,
  constraints TEXT DEFAULT '',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Workout Plans table
CREATE TABLE IF NOT EXISTS workout_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  duration_weeks INTEGER NOT NULL,
  training_split TEXT NOT NULL,
  workouts JSONB NOT NULL,
  generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ai_model TEXT NOT NULL DEFAULT 'proxy',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Workout Sessions table
CREATE TABLE IF NOT EXISTS workout_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  workout_id TEXT NOT NULL,
  date DATE NOT NULL,
  duration_minutes INTEGER NOT NULL,
  completed BOOLEAN NOT NULL DEFAULT FALSE,
  sets_logged JSONB NOT NULL,
  total_volume_lbs DOUBLE PRECISION NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_workout_plans_user_id ON workout_plans(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_plans_start_date ON workout_plans(start_date);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_id ON workout_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_workout_sessions_date ON workout_sessions(date);
