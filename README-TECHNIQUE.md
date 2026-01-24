# 🏋️ GymTracker - Documentation Technique

## 📖 Table des matières

1. [Architecture](#architecture)
2. [Structure du code](#structure-du-code)
3. [Stockage des données](#stockage-des-données)
4. [Composants React](#composants-react)
5. [Ajouter des fonctionnalités](#ajouter-des-fonctionnalités)
6. [Migration vers Supabase](#migration-vers-supabase)

---

## 🏗️ Architecture

### Stack technique
- **Frontend** : React 18 (via CDN)
- **Styling** : CSS vanilla (pas de framework)
- **Stockage** : LocalStorage (navigateur)
- **PWA** : Service Worker basique
- **Build** : Aucun (fichier HTML standalone)

### Pourquoi cette approche ?
- ✅ **Simple** : Un seul fichier HTML, pas de build
- ✅ **Rapide** : Pas de npm install, pas de dépendances
- ✅ **Gratuit** : Hébergement Vercel gratuit
- ✅ **Évolutif** : Facile de migrer vers Supabase plus tard

---

## 📂 Structure du code

Le fichier `gym-tracker.html` contient tout :

```
gym-tracker.html
├── <head>
│   ├── Meta tags (PWA, viewport)
│   └── Styles CSS
├── <body>
│   └── <div id="root"> (point de montage React)
└── <script type="text/babel">
    ├── Utilitaires (storage, generateId)
    ├── Composant App (principal)
    ├── Composant ProgramsView
    ├── Composant WorkoutView
    ├── Composant Modal
    └── ReactDOM.render()
```

---

## 💾 Stockage des données

### Structure de données

```javascript
// LocalStorage key: 'gym_programs'
[
  {
    id: "abc123",              // ID unique généré
    name: "PPL Split",         // Nom du programme
    sessions: [                // Liste des séances
      {
        id: "def456",
        name: "Push",
        exercises: [           // Liste des exercices
          {
            id: "ghi789",
            name: "Développé Couché",
            sets: 4,           // Nombre de séries
            restTime: 90       // Temps de repos en secondes
          }
        ]
      }
    ],
    createdAt: 1234567890      // Timestamp
  }
]
```

### Fonctions de stockage

```javascript
// Récupérer les données
const programs = storage.get('gym_programs') || [];

// Sauvegarder les données
storage.set('gym_programs', programs);
```

### ⚠️ Limitations du LocalStorage
- **Capacité** : ~5-10 MB selon le navigateur
- **Persistance** : Si l'utilisateur efface les données du navigateur, tout est perdu
- **Synchronisation** : Aucune (données uniquement sur cet appareil)
- **Solution** : Migrer vers Supabase pour la prod

---

## ⚛️ Composants React

### 1. App (composant principal)

**Responsabilités :**
- Gère l'état global (programmes, vue active, workout en cours)
- Navigation entre vues
- CRUD des programmes/séances/exercices

**State principal :**
```javascript
const [view, setView] = useState('programs');        // Vue active
const [programs, setPrograms] = useState([]);        // Liste des programmes
const [showModal, setShowModal] = useState(false);   // Affichage modal
const [activeWorkout, setActiveWorkout] = useState(null); // Séance en cours
```

**Fonctions clés :**
```javascript
addProgram(name)                    // Créer un programme
addSession(programId, name)         // Ajouter une séance à un programme
addExercise(programId, sessionId, data) // Ajouter un exercice
startWorkout(program, session)      // Démarrer une séance
```

---

### 2. ProgramsView

**Responsabilités :**
- Afficher la liste des programmes
- Navigation dans l'arborescence (programmes → séances → exercices)
- Boutons d'action (créer, supprimer, démarrer)

**Props :**
```javascript
{
  programs,           // Liste des programmes
  onAddProgram,       // Callback pour créer un programme
  onDeleteProgram,    // Callback pour supprimer
  onAddSession,       // Callback pour ajouter une séance
  onStartWorkout,     // Callback pour démarrer l'entraînement
  // ...
}
```

**State local :**
```javascript
const [expandedProgram, setExpandedProgram] = useState(null);
const [expandedSession, setExpandedSession] = useState(null);
```

---

### 3. WorkoutView

**Responsabilités :**
- Afficher l'exercice en cours
- Tracking des séries (reps, poids)
- Timer de repos automatique
- Navigation entre exercices

**Props :**
```javascript
{
  workout,            // Objet workout avec tous les exercices
  onUpdateWorkout,    // Callback pour mettre à jour
  onEndWorkout        // Callback pour terminer
}
```

**State local :**
```javascript
const [currentExerciseIndex, setCurrentExerciseIndex] = useState(0);
const [restTimer, setRestTimer] = useState(null);     // Durée du timer actif
const [restRemaining, setRestRemaining] = useState(0); // Temps restant
```

**Timer de repos :**
```javascript
useEffect(() => {
  if (restTimer !== null) {
    const startTime = Date.now();
    const endTime = startTime + restTimer * 1000;

    timerRef.current = setInterval(() => {
      const remaining = Math.max(0, Math.ceil((endTime - Date.now()) / 1000));
      setRestRemaining(remaining);

      if (remaining === 0) {
        clearInterval(timerRef.current);
        setRestTimer(null);
        // Vibration
        if (navigator.vibrate) {
          navigator.vibrate([200, 100, 200]);
        }
      }
    }, 100);

    return () => clearInterval(timerRef.current);
  }
}, [restTimer]);
```

---

### 4. Modal

**Responsabilités :**
- Formulaires de création (programme, séance, exercice)
- Validation des inputs

**Props :**
```javascript
{
  type,              // 'program' | 'session' | 'exercise'
  program,           // Programme parent (si applicable)
  session,           // Séance parente (si applicable)
  onClose,           // Callback pour fermer
  onAddProgram,      // Callback création programme
  onAddSession,      // Callback création séance
  onAddExercise      // Callback création exercice
}
```

---

## 🛠️ Ajouter des fonctionnalités

### Exemple 1 : Ajouter des notes sur les séries

**1. Modifier la structure de données :**
```javascript
// Dans addExercise, ajouter :
{
  id: generateId(),
  name: exerciseData.name,
  sets: parseInt(exerciseData.sets),
  restTime: parseInt(exerciseData.restTime),
  notes: ''  // ← NOUVEAU
}
```

**2. Modifier le formulaire (Modal) :**
```javascript
// Ajouter dans le JSX du Modal, après restTime :
<div className="form-group">
  <label className="form-label">Notes (optionnel)</label>
  <textarea
    className="form-input"
    value={formData.notes}
    onChange={(e) => setFormData({ ...formData, notes: e.target.value })}
    placeholder="Ex: Utiliser la prise large"
    rows="3"
  />
</div>
```

**3. Afficher les notes dans WorkoutView :**
```javascript
// Sous le titre de l'exercice :
{currentExercise.notes && (
  <div style={{ 
    fontSize: '12px', 
    color: 'var(--text-secondary)', 
    marginTop: '8px',
    fontStyle: 'italic'
  }}>
    📝 {currentExercise.notes}
  </div>
)}
```

---

### Exemple 2 : Sauvegarder l'historique des séances

**1. Ajouter un state pour l'historique :**
```javascript
const [workoutHistory, setWorkoutHistory] = useState([]);

useEffect(() => {
  const history = storage.get('workout_history') || [];
  setWorkoutHistory(history);
}, []);

useEffect(() => {
  storage.set('workout_history', workoutHistory);
}, [workoutHistory]);
```

**2. Sauvegarder quand on termine une séance :**
```javascript
const endWorkout = () => {
  const completedWorkout = {
    ...activeWorkout,
    completedAt: Date.now(),
    duration: Date.now() - activeWorkout.startedAt
  };
  
  setWorkoutHistory([completedWorkout, ...workoutHistory]);
  setActiveWorkout(null);
  setView('programs');
};
```

**3. Créer une vue "Historique" :**
```javascript
// Ajouter un bouton dans le nav
<button 
  className={`nav-btn ${view === 'history' ? 'active' : ''}`}
  onClick={() => setView('history')}
>
  Historique
</button>

// Créer le composant HistoryView
function HistoryView({ history }) {
  return (
    <div className="view active">
      {history.map(workout => (
        <div key={workout.completedAt} className="card">
          <div className="card-title">{workout.session.name}</div>
          <div className="card-meta">
            {new Date(workout.completedAt).toLocaleDateString()} •
            Durée: {Math.round((workout.completedAt - workout.startedAt) / 60000)}min
          </div>
        </div>
      ))}
    </div>
  );
}
```

---

### Exemple 3 : Calculer le volume total (reps × poids)

**1. Dans WorkoutView, ajouter une fonction :**
```javascript
const calculateVolume = (exercise) => {
  return exercise.sets.reduce((total, set) => {
    if (set.completed && set.reps && set.weight) {
      return total + (parseInt(set.reps) * parseFloat(set.weight));
    }
    return total;
  }, 0);
};
```

**2. Afficher le volume :**
```javascript
<div style={{ marginTop: '12px', fontSize: '14px', color: 'var(--success)' }}>
  Volume total: {calculateVolume(currentExercise)} kg
</div>
```

---

## ☁️ Migration vers Supabase

### Pourquoi migrer ?
- ✅ **Synchronisation** multi-appareils
- ✅ **Backup** automatique
- ✅ **Multi-utilisateurs** (authentification)
- ✅ **Requêtes complexes** (stats, graphiques)

### Étapes de migration

#### 1. Créer un compte Supabase
```bash
# https://supabase.com
# Sign up (gratuit jusqu'à 500 MB)
# Créer un nouveau projet
```

#### 2. Créer les tables

**Table `profiles` (utilisateurs) :**
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**Table `programs` :**
```sql
CREATE TABLE programs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**Table `sessions` :**
```sql
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  program_id UUID REFERENCES programs(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**Table `exercises` :**
```sql
CREATE TABLE exercises (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id UUID REFERENCES sessions(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  sets INTEGER NOT NULL,
  rest_time INTEGER NOT NULL,
  notes TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
```

**Table `workout_history` :**
```sql
CREATE TABLE workout_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  session_id UUID REFERENCES sessions(id),
  started_at TIMESTAMP NOT NULL,
  completed_at TIMESTAMP NOT NULL,
  data JSONB NOT NULL, -- Stocke toutes les séries
  created_at TIMESTAMP DEFAULT NOW()
);
```

#### 3. Installer Supabase dans le code

```html
<!-- Ajouter dans le <head> -->
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
```

```javascript
// Initialiser Supabase
const supabase = window.supabase.createClient(
  'VOTRE_SUPABASE_URL',
  'VOTRE_SUPABASE_ANON_KEY'
);
```

#### 4. Remplacer LocalStorage par Supabase

**Avant (LocalStorage) :**
```javascript
const programs = storage.get('gym_programs') || [];
```

**Après (Supabase) :**
```javascript
const { data: programs, error } = await supabase
  .from('programs')
  .select(`
    *,
    sessions (
      *,
      exercises (*)
    )
  `)
  .eq('user_id', user.id);
```

#### 5. Ajouter l'authentification

```javascript
// Login
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password123'
});

// Signup
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password123'
});

// Get current user
const { data: { user } } = await supabase.auth.getUser();
```

#### 6. Créer un composant Auth

```javascript
function AuthView({ onLogin }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = async (e) => {
    e.preventDefault();
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password
    });
    
    if (!error) {
      onLogin(data.user);
    }
  };

  return (
    <form onSubmit={handleLogin}>
      <input 
        type="email" 
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        placeholder="Email"
      />
      <input 
        type="password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        placeholder="Mot de passe"
      />
      <button type="submit">Connexion</button>
    </form>
  );
}
```

---

## 🎨 Personnalisation CSS

### Variables CSS principales

```css
:root {
  --bg-primary: #080808;      /* Fond principal (noir) */
  --bg-secondary: #141414;    /* Fond cartes */
  --bg-tertiary: #1F1F1F;     /* Fond inputs */
  --text-primary: #FAFAFA;    /* Texte principal */
  --text-secondary: #A0A0A0;  /* Texte secondaire */
  --accent: #FF4500;          /* Couleur principale (orange) */
  --accent-hover: #FF6B35;    /* Hover */
  --success: #00FF87;         /* Succès / Timer (vert) */
  --border: #2A2A2A;          /* Bordures */
}
```

### Thèmes alternatifs

**Thème Bleu Cyberpunk :**
```css
:root {
  --bg-primary: #0a0e27;
  --bg-secondary: #151a30;
  --bg-tertiary: #1e2642;
  --accent: #00d9ff;
  --success: #ff00ff;
}
```

**Thème Minimal Blanc :**
```css
:root {
  --bg-primary: #ffffff;
  --bg-secondary: #f5f5f5;
  --bg-tertiary: #e0e0e0;
  --text-primary: #000000;
  --text-secondary: #666666;
  --accent: #000000;
  --success: #00c853;
  --border: #d0d0d0;
}
```

---

## 🐛 Debugging

### Voir les données stockées

```javascript
// Dans la console (F12 → Console)
console.log(JSON.parse(localStorage.getItem('gym_programs')));
```

### Réinitialiser les données

```javascript
localStorage.removeItem('gym_programs');
window.location.reload();
```

### Logs utiles

```javascript
// Dans App()
console.log('Programs:', programs);
console.log('Active workout:', activeWorkout);

// Dans WorkoutView()
console.log('Current exercise:', currentExercise);
console.log('Rest timer:', restTimer, 'Remaining:', restRemaining);
```

---

## 📚 Ressources d'apprentissage

### React
- [React Docs](https://react.dev/learn) - Documentation officielle
- [useState Hook](https://react.dev/reference/react/useState)
- [useEffect Hook](https://react.dev/reference/react/useEffect)

### CSS
- [CSS Tricks](https://css-tricks.com) - Guides et astuces
- [Flexbox Guide](https://css-tricks.com/snippets/css/a-guide-to-flexbox/)
- [Grid Guide](https://css-tricks.com/snippets/css/complete-guide-grid/)

### JavaScript
- [MDN JavaScript](https://developer.mozilla.org/fr/docs/Web/JavaScript)
- [Array methods](https://developer.mozilla.org/fr/docs/Web/JavaScript/Reference/Global_Objects/Array)
- [LocalStorage](https://developer.mozilla.org/fr/docs/Web/API/Window/localStorage)

### Supabase
- [Supabase Docs](https://supabase.com/docs)
- [Auth Guide](https://supabase.com/docs/guides/auth)
- [Database Guide](https://supabase.com/docs/guides/database)

---

## 🚀 Optimisations futures

### Performance
- [ ] Lazy loading des exercices
- [ ] Virtualisation des listes longues
- [ ] Service Worker avec cache stratégique
- [ ] Compression des données

### UX
- [ ] Animations de transition
- [ ] Swipe gestures
- [ ] Mode sombre/clair toggle
- [ ] Haptic feedback
- [ ] Raccourcis clavier

### Features
- [ ] Export PDF des programmes
- [ ] Import/Export JSON
- [ ] Templates de programmes populaires
- [ ] Mode hors-ligne robuste
- [ ] Notifications programmées

---

**Bon code ! 💻**
