-- ============================================
-- GymTracker - Row Level Security (RLS) Policies
-- ============================================
-- Ce script configure les politiques de sécurité pour isoler
-- les données de chaque utilisateur dans Supabase.
--
-- Pour appliquer :
-- 1. Allez sur https://supabase.com/dashboard
-- 2. Sélectionnez votre projet
-- 3. Allez dans SQL Editor
-- 4. Collez et exécutez ce script
-- ============================================

-- ============================================
-- ÉTAPE 1 : Activer RLS sur toutes les tables
-- ============================================

ALTER TABLE programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_history ENABLE ROW LEVEL SECURITY;

-- ============================================
-- ÉTAPE 2 : Politiques pour PROGRAMS
-- ============================================
-- La table programs a un champ user_id direct

CREATE POLICY "Users can view their own programs"
ON programs FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own programs"
ON programs FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own programs"
ON programs FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own programs"
ON programs FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- ÉTAPE 3 : Politiques pour SESSIONS
-- ============================================
-- La table sessions n'a pas de user_id direct
-- L'isolation passe par program_id -> programs.user_id

CREATE POLICY "Users can view sessions of their programs"
ON sessions FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM programs
    WHERE programs.id = sessions.program_id
    AND programs.user_id = auth.uid()
  )
);

CREATE POLICY "Users can insert sessions in their programs"
ON sessions FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM programs
    WHERE programs.id = program_id
    AND programs.user_id = auth.uid()
  )
);

CREATE POLICY "Users can update sessions in their programs"
ON sessions FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM programs
    WHERE programs.id = sessions.program_id
    AND programs.user_id = auth.uid()
  )
);

CREATE POLICY "Users can delete sessions in their programs"
ON sessions FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM programs
    WHERE programs.id = sessions.program_id
    AND programs.user_id = auth.uid()
  )
);

-- ============================================
-- ÉTAPE 4 : Politiques pour EXERCISES
-- ============================================
-- La table exercises n'a pas de user_id direct
-- L'isolation passe par session_id -> sessions.program_id -> programs.user_id

CREATE POLICY "Users can view exercises of their sessions"
ON exercises FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM sessions
    JOIN programs ON programs.id = sessions.program_id
    WHERE sessions.id = exercises.session_id
    AND programs.user_id = auth.uid()
  )
);

CREATE POLICY "Users can insert exercises in their sessions"
ON exercises FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM sessions
    JOIN programs ON programs.id = sessions.program_id
    WHERE sessions.id = session_id
    AND programs.user_id = auth.uid()
  )
);

CREATE POLICY "Users can update exercises in their sessions"
ON exercises FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM sessions
    JOIN programs ON programs.id = sessions.program_id
    WHERE sessions.id = exercises.session_id
    AND programs.user_id = auth.uid()
  )
);

CREATE POLICY "Users can delete exercises in their sessions"
ON exercises FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM sessions
    JOIN programs ON programs.id = sessions.program_id
    WHERE sessions.id = exercises.session_id
    AND programs.user_id = auth.uid()
  )
);

-- ============================================
-- ÉTAPE 5 : Politiques pour WORKOUT_HISTORY
-- ============================================
-- La table workout_history a un champ user_id direct

CREATE POLICY "Users can view their own workout history"
ON workout_history FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own workout history"
ON workout_history FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own workout history"
ON workout_history FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own workout history"
ON workout_history FOR DELETE
USING (auth.uid() = user_id);

-- ============================================
-- VÉRIFICATION (optionnel)
-- ============================================
-- Pour vérifier que RLS est activé sur vos tables :
-- SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public';
