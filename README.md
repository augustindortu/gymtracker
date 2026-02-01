# GymTracker 💪

Application web de suivi d'entraînement en musculation.

## Fonctionnalités

- ✅ Création de programmes et séances personnalisées
- ✅ Suivi en temps réel avec timer de repos
- ✅ Détection automatique des records personnels
- ✅ Historique complet des performances
- ✅ Réordonnancement des exercices par drag & drop

## Stack Technique

- **Frontend**: React 18 (via CDN)
- **Backend**: Supabase (PostgreSQL + Auth)
- **Style**: CSS vanilla

## Installation

1. Créer un projet sur [Supabase](https://supabase.com)
2. Exécuter les scripts SQL du dossier `sql/`
3. Mettre à jour les clés Supabase dans `index.html`
4. Ouvrir `index.html` dans un navigateur

## Structure

```
gymtracker/
├── index.html          # Application React
├── css/
│   └── styles.css      # Styles
├── sql/
│   ├── migration-position.sql
│   └── rls-policies.sql
└── specifications_fonctionnelles.md
```
