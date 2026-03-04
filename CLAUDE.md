# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running the App

No build step. Open `index.html` directly in a browser, or serve it with any static file server:

```sh
python3 -m http.server 8080
# or
npx serve .
```

The app uses React 18 + Babel via CDN — no npm, no bundler.

## Architecture

**Single-file React app**: All application logic lives in `index.html` inside a `<script type="text/babel">` tag. React components, Supabase queries, and state management are all in that one file. `css/styles.css` holds all styles.

**Key sections in `index.html`** (in order):
1. `SUPABASE_URL` / `SUPABASE_ANON_KEY` — credentials at the top
2. `Icon` component — inline SVG Lucide icons, rendered as `<Icon name="..." size={N} />`
3. `db` object — all Supabase queries (programs, sessions, exercises, workout_history, profiles)
4. React components — `App`, `ProgramsView`, `WorkoutView`, `HistoryView`, `AccountView`, `AuthView`
5. `ReactDOM.createRoot(...).render(...)` — mount point

**Data flow**: `App` component owns all state. `loadData(userId)` fetches everything on login. State is passed down as props; mutations call `db.*` then re-run `loadData`.

**Active workout persistence**: Stored in `localStorage` under `gymtracker_active_workout`. Restored on page reload; reset if older than 6h.

## Database (Supabase)

**Tables**: `profiles`, `programs`, `sessions`, `exercises`, `workout_history`

**RLS**: All tables have Row Level Security enabled. See `sql/rls-policies.sql` for policies.

**Migrations** (run in order if setting up fresh):
1. `sql/rls-policies.sql`
2. `sql/migration-position.sql` — adds `position` column to `exercises`
3. `sql/migration-profiles.sql` — adds `first_name`, `last_name`, `height`, `weight`, `updated_at` to `profiles`
4. `sql/migration-default-program.sql` — creates `create_default_program()` function + `handle_new_user` trigger

**Trigger**: On new user signup, `handle_new_user` creates a profile row and calls `create_default_program(user_id)` which seeds the "Push Pull Leg FB" programme. Functions must use `SET search_path = public` and prefix all table references with `public.` because `supabase_auth_admin` doesn't have `public` in its `search_path`.

**Profile update**: Always use `update` (not `upsert`) — the trigger guarantees the row exists. Always include `email` since it has a NOT NULL constraint.

## Design System

CSS variables defined in `css/styles.css`:
- `--primary`: `#1E3A5F` (deep blue — text, headings, nav active)
- `--accent`: `#FF6B35` (orange — CTA buttons, active state, current-week bar)
- `--success`: `#10B981` (green — rest timer background)
- `--danger`: `#EF4444` (red — delete actions)
- Font: Plus Jakarta Sans (Google Fonts), weights 400–800

**Button hierarchy** (Programmes view, high → low priority):
1. `btn-quick-start` — round 40px orange, starts a session
2. Orange full-width button — starts session when expanded
3. Grey secondary — create/add actions
4. `btn-ghost-danger` — delete session (red text, no border)
5. `btn-ghost-muted` — delete programme (grey text, no border)

## Functional Specs

Full detailed specs (data model, component behaviour, UI specs) are in `specifications_fonctionnelles.md`. Consult it before adding or modifying any feature — it documents expected behaviour precisely (e.g. auto-expand single programme, banner dismiss timing, stat calculation rules).
