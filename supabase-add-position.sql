-- ============================================
-- GymTracker - Migration: Ajout colonne position
-- ============================================
-- Ce script ajoute la colonne 'position' à la table exercises
-- pour permettre le réordonnancement des exercices.
--
-- Pour appliquer :
-- 1. Allez sur https://supabase.com/dashboard
-- 2. Sélectionnez votre projet
-- 3. Allez dans SQL Editor
-- 4. Collez et exécutez ce script
-- ============================================

-- ÉTAPE 1 : Ajouter la colonne position
ALTER TABLE exercises ADD COLUMN IF NOT EXISTS position INTEGER DEFAULT 0;

-- ÉTAPE 2 : Backfill des positions existantes
-- Attribue une position séquentielle (0, 1, 2...) par session
-- basée sur l'ordre de création
WITH numbered AS (
  SELECT
    id,
    ROW_NUMBER() OVER (PARTITION BY session_id ORDER BY id) - 1 as pos
  FROM exercises
)
UPDATE exercises
SET position = numbered.pos
FROM numbered
WHERE exercises.id = numbered.id;

-- ÉTAPE 3 : Rendre la colonne NOT NULL après le backfill
ALTER TABLE exercises ALTER COLUMN position SET NOT NULL;

-- ÉTAPE 4 : Créer un index pour optimiser les requêtes de tri
CREATE INDEX IF NOT EXISTS idx_exercises_session_position
ON exercises(session_id, position);

-- ============================================
-- VÉRIFICATION
-- ============================================
-- Pour vérifier que la migration a fonctionné :
-- SELECT session_id, name, position FROM exercises ORDER BY session_id, position;
