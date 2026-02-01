-- ============================================
-- GymTracker - Migration: Table Profiles
-- ============================================
-- Ce script crée la table profiles pour stocker
-- les informations personnelles des utilisateurs.
--
-- Pour appliquer :
-- 1. Allez sur https://supabase.com/dashboard
-- 2. Sélectionnez votre projet
-- 3. Allez dans SQL Editor
-- 4. Collez et exécutez ce script
-- ============================================

-- ============================================
-- ÉTAPE 1 : Créer la table profiles
-- ============================================

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  first_name TEXT,
  last_name TEXT,
  height INTEGER, -- Taille en cm
  weight DECIMAL(5,2), -- Poids en kg (ex: 75.50)
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- ÉTAPE 2 : Activer RLS sur la table profiles
-- ============================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- ============================================
-- ÉTAPE 3 : Politiques RLS pour profiles
-- ============================================

-- Politique SELECT : Un utilisateur ne peut voir que son propre profil
CREATE POLICY "Users can view their own profile"
ON profiles FOR SELECT
USING (auth.uid() = id);

-- Politique INSERT : Un utilisateur ne peut créer que son propre profil
CREATE POLICY "Users can insert their own profile"
ON profiles FOR INSERT
WITH CHECK (auth.uid() = id);

-- Politique UPDATE : Un utilisateur ne peut modifier que son propre profil
CREATE POLICY "Users can update their own profile"
ON profiles FOR UPDATE
USING (auth.uid() = id);

-- Politique DELETE : Un utilisateur ne peut supprimer que son propre profil
CREATE POLICY "Users can delete their own profile"
ON profiles FOR DELETE
USING (auth.uid() = id);

-- ============================================
-- ÉTAPE 4 : Fonction pour créer automatiquement
-- un profil lors de l'inscription
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger qui s'exécute après chaque nouvelle inscription
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- ÉTAPE 5 : Fonction pour mettre à jour updated_at
-- ============================================

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- VÉRIFICATION (optionnel)
-- ============================================
-- Pour vérifier que la table a été créée :
-- SELECT * FROM profiles;
--
-- Pour vérifier les politiques RLS :
-- SELECT * FROM pg_policies WHERE tablename = 'profiles';
