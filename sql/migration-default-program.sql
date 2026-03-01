-- ============================================================
-- Migration : Programme par défaut pour les nouveaux comptes
-- Crée automatiquement "Push Pull Leg FB" (4 séances, 24 exercices)
-- à chaque nouvelle inscription.
-- ============================================================


-- Étape 1 : Fonction helper qui crée le programme par défaut
-- ============================================================
CREATE OR REPLACE FUNCTION public.create_default_program(p_user_id UUID)
RETURNS VOID AS $$
DECLARE
  v_program_id UUID;
  v_session_push_id UUID;
  v_session_pull_id UUID;
  v_session_leg_id UUID;
  v_session_fb_id UUID;
BEGIN
  -- Programme
  INSERT INTO programs (user_id, name)
    VALUES (p_user_id, 'Push Pull Leg FB')
    RETURNING id INTO v_program_id;

  -- Séances (dans l'ordre d'affichage)
  INSERT INTO sessions (program_id, name) VALUES (v_program_id, 'Push')      RETURNING id INTO v_session_push_id;
  INSERT INTO sessions (program_id, name) VALUES (v_program_id, 'Pull')      RETURNING id INTO v_session_pull_id;
  INSERT INTO sessions (program_id, name) VALUES (v_program_id, 'Leg')       RETURNING id INTO v_session_leg_id;
  INSERT INTO sessions (program_id, name) VALUES (v_program_id, 'Full Body') RETURNING id INTO v_session_fb_id;

  -- Push (6 exercices)
  INSERT INTO exercises (session_id, name, sets, rest_time, notes, position) VALUES
    (v_session_push_id, 'Développé Couché',                    4, 180, 'À la barre',                         0),
    (v_session_push_id, 'Développé incliné',                   3, 120, 'Banc incliné / haltères',            1),
    (v_session_push_id, 'Tirage menton + DM en unilatéral',    3, 120, '',                                   2),
    (v_session_push_id, 'Pec fly',                             3, 120, 'Alternative : Écarté poulies basses', 3),
    (v_session_push_id, 'Triceps Poulie',                      3, 120, '',                                   4),
    (v_session_push_id, 'Écartés latéral',                     3, 120, 'Aux haltères',                      5);

  -- Pull (6 exercices, triés par position)
  INSERT INTO exercises (session_id, name, sets, rest_time, notes, position) VALUES
    (v_session_pull_id, 'Muscle Up',                     3, 180, 'Sans elastiques',                                              0),
    (v_session_pull_id, 'Tractions lestées',             4, 180, '',                                                             1),
    (v_session_pull_id, 'Rowing Poulie Prise Neutre',    3, 120, '',                                                             2),
    (v_session_pull_id, 'Tirage Vertical Prise Neutre',  3, 120, '',                                                             3),
    (v_session_pull_id, 'Rear Delt',                     3,  90, '',                                                             4),
    (v_session_pull_id, 'Curl Biceps Pupitre assis',     3, 120, 'Barre EZ' || chr(10) || 'Pupitre assis' || chr(10) || 'Siège à 8', 5);

  -- Leg (6 exercices, triés par position)
  INSERT INTO exercises (session_id, name, sets, rest_time, notes, position) VALUES
    (v_session_leg_id, 'Squat',               3, 180, 'À la barre',                                                                           0),
    (v_session_leg_id, 'Presse leg',          3, 150, '',                                                                                      1),
    (v_session_leg_id, 'Relevé de jambes',    3, 150, '10 jambes tendues tête la 1ere série puis 10 jambes tendues tête puis 10 genoux',       2),
    (v_session_leg_id, 'Leg extension',       3, 150, '',                                                                                      3),
    (v_session_leg_id, 'Leg curl',            3, 150, 'Siège à 6, pieds à 3',                                                                  4),
    (v_session_leg_id, 'Crunch à la machine', 2, 150, '',                                                                                      5);

  -- Full Body (6 exercices)
  INSERT INTO exercises (session_id, name, sets, rest_time, notes, position) VALUES
    (v_session_fb_id, 'Développé couché (FB)',     4, 180, '',             0),
    (v_session_fb_id, 'Squat (FB)',                3, 180, '',             1),
    (v_session_fb_id, 'Tractions lestées (FB)',    4, 180, '',             2),
    (v_session_fb_id, 'Contractions mollet',       3,  90, 'Sur un step', 3),
    (v_session_fb_id, 'Curl assis incliné (FB)',   3, 120, '',             4),
    (v_session_fb_id, 'Curl triceps allongé (FB)', 2, 120, '',             5);

END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- Étape 2 : Mise à jour du trigger handle_new_user existant
--           pour appeler create_default_program après inscription
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Comportement existant : créer le profil vide
  INSERT INTO public.profiles (id) VALUES (NEW.id);

  -- Nouveau : créer le programme par défaut
  PERFORM public.create_default_program(NEW.id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Le trigger on_auth_user_created est déjà en place, pas besoin de le recréer.
