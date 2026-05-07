# Medity — Project Context

> **Lis ce fichier en premier à chaque nouvelle session.** Il contient la spec, la stack, l'architecture, les conventions, et un résumé du design system. Pour les détails design, voir `design/DESIGN_SYSTEM.md`.

---

## Vue d'ensemble

**Medity** est une app iOS de méditation minimaliste : timer, sons, stats. **Pas de méditation guidée**. L'app vise un public qui veut juste un beau timer pour méditer en silence ou avec un son d'ambiance.

**Auteur** : Aituglo (solo)
**Plateformes** : iOS uniquement (V1). Pas d'iPad ni de Watch en V1.
**Cible commerciale** : entièrement gratuite, sans publicité, sans IAP. App perso de l'auteur, partagée librement.

---

## Stack technique

- **SwiftUI** natif. Pas de React Native, pas de Flutter.
- **iOS 26.0+** minimum (Xcode 26 / Swift 6.3+) — pour avoir l'API native Liquid Glass (`.glassEffect()`).
- **SwiftData + CloudKit** pour le stockage offline-first avec sync iCloud (DB privée).
- **HealthKit** : write `mindfulSession` à chaque méditation. Read si dispo (HRV / heart rate / sleep — l'utilisateur porte une Oura ring qui écrit dans HealthKit).
- **WidgetKit** pour les widgets home + lock screen (streak, dernière session, semaine).
- **ActivityKit** pour la Live Activity (Dynamic Island pendant une session).
- **AVFoundation** pour les sons d'ambiance (loop seamless) et les cloches.
- **CoreHaptics** pour les patterns haptiques (begin / bell interval / complete).
- **UserNotifications** pour le rappel quotidien.

Pas de backend. Tout est local + iCloud.

---

## Architecture

Pattern : **MVVM léger** (SwiftUI + `@Observable` ViewModels, pas de Combine sauf nécessaire). Chaque feature dans son dossier, avec sa View + son ViewModel + ses sous-vues.

### Layout du projet

```
Medity/
├── Medity.xcodeproj/             # généré par xcodegen — NE PAS éditer à la main
├── project.yml                   # source de vérité du projet Xcode
├── CLAUDE.md                     # ce fichier
├── design/                       # bundle Claude Design + DESIGN_SYSTEM.md
└── Medity/
    ├── App/
    │   └── MedityApp.swift       # @main entry point
    ├── DesignSystem/             # tokens + composants réutilisables
    │   ├── Tokens.swift          # Color, Font, Spacing, Radius
    │   ├── Backdrop.swift        # ambient mood gradient backgrounds
    │   ├── AuraView.swift        # soft glow circle
    │   ├── GlassSurface.swift    # glass modifier (ultraThinMaterial)
    │   ├── PrimaryButton.swift   # full-width pill CTA
    │   └── CairnMark.swift       # logo Shape (3 stones)
    ├── Features/
    │   ├── Onboarding/
    │   ├── Home/                 # timer setup (ring + presets + sound/bells pills)
    │   ├── Session/              # in-progress + complete
    │   ├── Sounds/               # sound library sheet
    │   ├── Bells/                # bells picker sheet
    │   ├── Stats/                # streak + heatmap + metrics + line graph
    │   ├── Achievements/         # markers grid + detail
    │   ├── Settings/
    │   └── Paywall/
    ├── Models/                   # SwiftData @Model types
    ├── Services/
    │   ├── Audio/                # AVFoundation loops + bell ducking
    │   ├── HealthKit/
    │   ├── Haptics/
    │   ├── Notifications/
    │   └── (no IAP)
    └── Resources/
        ├── Assets.xcassets/
        ├── Fonts/                # Geist (à ajouter)
        └── Sounds/               # bells + ambient loops (.caf preferable)
```

### Modèles SwiftData (V1)

```swift
@Model final class Session {
    var id: UUID
    var startedAt: Date
    var endedAt: Date
    var plannedDurationSeconds: Int
    var actualDurationSeconds: Int
    var soundIdentifier: String?      // "rain.light", "ocean.waves", nil = silence
    var bellIdentifier: String        // "tibetan-bowl", etc.
    var intervalBellsMinutes: Int?    // 5, 10, 15, nil = off
    var completed: Bool
    var averageHeartRate: Int?        // populated from HealthKit if available
}

@Model final class StreakState {
    // Singleton-like. Tracks current streak, longest, last session date, freezes.
    var currentStreak: Int
    var longestStreak: Int
    var lastSessionDate: Date?
    var freezesUsedThisWeek: Int      // indulgent: 1 freeze allowed per 7 days
    var weekStartDate: Date            // for resetting freezes
}

@Model final class UserPreferences {
    var defaultDurationSeconds: Int
    var defaultSoundIdentifier: String?
    var defaultBellIdentifier: String
    var defaultIntervalBellsMinutes: Int?
    var reminderEnabled: Bool
    var reminderTime: Date            // time-of-day component
    var reminderDays: Int              // bitfield 0b1111111 = all days
}
```

(Les modèles seront affinés au moment de leur implémentation — c'est une référence directionnelle.)

---

## Design system (résumé)

> Pour le détail complet (tokens, composants, écrans, motion, audio, haptiques) voir `design/DESIGN_SYSTEM.md`. Le prototype JSX est dans `design/`.

### Direction visuelle

- **Light mode only** (V1)
- **Liquid Glass-inspired** — surfaces translucides avec blur/material, dépth subtile
- **Tons neutres bleutés** + accent chaud pour les célébrations
- **Typo Geist** uniquement (sans-serif), light weights pour les gros chiffres
- **Mood** : monastique, silencieux, généreux en whitespace, pas d'emoji

### Tokens couleur (à coder dans `DesignSystem/Tokens.swift`)

| Token             | Hex       | Rôle                              |
|-------------------|-----------|-----------------------------------|
| `appBackground`   | `#F4F6F9` | Fond app                          |
| `ink`             | `#0F1B2D` | Texte primaire, gros chiffres     |
| `inkSecondary`    | `#6B7891` | Texte secondaire                  |
| `inkTertiary`     | `#A8B0BF` | Captions, eyebrow labels          |
| `accent`          | `#4A6FA5` | Accent froid (chrome, links)      |
| `warmAccent`      | `#C68B5C` | Accent chaud (streak, unlock)     |
| `warmAccentSoft`  | `#E8C9A8` | Aura chaude                       |
| `aura`            | `#C9D6E8` | Glow / aura derrière le timer     |
| `hairline`        | rgba(0F1B2D / 6%) | Séparateurs subtils       |
| `hairlineStrong`  | rgba(0F1B2D / 10%)| Séparateurs marqués       |

### Typo

- Famille : **Geist** (à embarquer en custom font, fallback `.system`)
- Échelle (sizes en pt) :
  - Hero numeral : 96–132, weight 200, tracking -2 à -5 (timer countdown, streak)
  - Display : 38–60, weight 200–300
  - Section title : 26–30, weight 400
  - Body : 15–17, weight 400
  - Eyebrow caps : 10.5–11, weight 500, tracking +2.5–3, uppercase
- `monospacedDigit()` pour le countdown du timer

### Composants clés (à implémenter dans `DesignSystem/`)

1. **`Backdrop`** — fond ambient avec 3 radials gradients superposés. Modes : `.dawn`, `.day`, `.dusk`, `.night`.
2. **`AuraView`** — cercle radial blurred (`.blur(40)`) derrière le timer.
3. **`GlassSurface` (modifier)** — `.ultraThinMaterial` + bordure `0.5px` blanche + ombres internes blanches + ombre externe diffuse. Variantes : `tint` (0.55 / 0.72 / 0.85), `blur`, `radius`.
4. **`TimerRing`** — vue custom (Canvas ou Shape composé). 60 ticks, arc de progress en gradient, drag handle, animation breathing 4s sur idle.
5. **`PrimaryButton`** — pill full-width 64pt, glass tint 0.65, icône (play/arrow) dans cercle `rgba(0F1B2D / 6%)` 36pt.
6. **`CairnMark`** — `Shape` du logo (3 pierres empilées).
7. **`HeatmapView`** — 26 weeks × 7 days, 5 niveaux d'opacité d'`accent`.

### Motion

- Ring idle : breathing scale `1.0 ↔ 1.03` sur 4s ease-in-out infini
- Particules session : ~22 dots accent, drift up lent
- Numérals countdown : `.contentTransition(.numericText())`, jamais de tick visuel
- Bell ducking : son de fond -6 dB sur 600 ms, hold, retour sur 1.2 s

### Audio

**Bibliothèque sons d'ambiance** (loop seamless, tout gratuit) :
- Nature : Rain Light, Rain Heavy, Ocean Waves, Ocean Shore, Forest, River, Fire, Wind
- Noise : Brown, Pink, White
- Music : Calm, Illusions, Japanese, Moonlight, Reverie, Spatium
- Stillness : Silence

**Cloches** (start / end / interval) : Tibetan bowl, Japanese bell, Gong, Soft chime, Deep bell, Wood block.

### Haptiques

| Trigger        | Pattern                                |
|----------------|----------------------------------------|
| Begin          | Soft tap puis breath pulse plus long   |
| Bell interval  | Deux whisper taps                      |
| Complete       | Trois soft pulses, espacés 0.5 s       |
| Pause / Resume | Soft tap                               |

---

## Conventions de code

### Style général

- **Swift 6**, strict concurrency activée. Async/await partout, pas de Combine sauf nécessaire.
- **`@Observable`** pour les ViewModels (pas `ObservableObject`).
- **`@Environment`** pour injecter services (HealthKit, Audio, Haptics).
- Pas de Singleton sauf vraiment nécessaire. Préférer DI via Environment.
- Identifiers de sons / cloches en `String` constantes typées (enum-like) — pas de magic strings.

### Nommage

- Vues SwiftUI : `XxxView` (sauf composants design system, e.g. `PrimaryButton`).
- ViewModels : `XxxViewModel`.
- Services : `XxxService` ou nom métier (`HealthStore`, `AudioPlayer`).
- Modèles SwiftData : nom métier au singulier (`Session`, pas `SessionModel`).

### Comments

- Anglais pour code/commentaires (français uniquement pour docs internes type CLAUDE.md, leads.md).
- Commentaires uniquement quand le **pourquoi** n'est pas évident (cf. instructions globales). Pas de "what".
- Documentation Swift `///` pour les API publiques du design system.

### Commits

- Messages en **français**, format conventional-ish : `feat:`, `fix:`, `chore:`, `docs:`, `design:`.
- Granulaires mais pas trop. Une feature = un commit ou un petit groupe.
- Toujours sur des branches feature, jamais directement sur `main` sauf bootstrap initial.

---

## Build & run

### Génération du projet Xcode

À chaque ajout/suppression de fichier `.swift` ou de modification de `project.yml` :

```sh
xcodegen generate
```

Important : xcodegen liste les fichiers explicitement dans le `.pbxproj` à la génération. Il **ne synchronise pas en continu**. Donc tout fichier ajouté pendant qu'Xcode est ouvert n'apparaîtra pas tant qu'on n'a pas régénéré (et redémarré Xcode si nécessaire).

### Build CLI

```sh
xcodebuild -project Medity.xcodeproj -scheme Medity -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

### Tests

(À ajouter quand on aura des tests. Cible `MedityTests` à créer plus tard.)

---

## Roadmap V1

1. ✅ **Bootstrap** — projet Xcode, design system fondations (Tokens, Backdrop, Aura, GlassSurface, CairnMark, PrimaryButton)
2. ✅ **Onboarding** — 3 écrans, demande de permissions Health + Notifications
3. ✅ **Home** — `TimerRing` (60 ticks, drag, breathing pulse), presets, pills sound/bells
4. ✅ **Session** — countdown serif, particules drift-up, pause, complete, haptics, idle-timer disabled
5. ✅ **Modèles + persistence** — SwiftData (Session + UserPreferences), HealthStore service, écriture Mindful Minutes
6. ✅ **Sound library** — sheet, 15 sons catalogued, 11 fichiers bundlés (Wikimedia CC/PD), AudioEngine procédural fallback
7. ✅ **Bells picker** — 5 timbres (4 synth + 1 file), interval bells 5/10/15 min, ducking pendant la cloche
8. ✅ **Stats** — streak hero, heatmap 26 weeks, 4 metrics 2x2, line graph 30 jours, empty state "First stone"
9. ✅ **Achievements** — 9 markers dérivés des sessions, grille + detail sheet
10. ✅ **Settings** — reminder schedule + ReminderScheduler, defaults, Health, About, Acknowledgements
11. ✅ **Widgets** — Streak (small/medium/large + lock-screen accessories), App Group `group.com.aituglo.medity`
12. ✅ **Live Activity** — Dynamic Island compact/minimal/expanded + Lock Screen, ActivityKit
13. ✅ **App icon** — cairn 1024x1024, gradient radial bleu doux
14. ✅ **CloudKit sync** — entitlement iCloud + ModelConfiguration `.private` (provisioning côté Apple Developer Portal)
15. ✅ **GitHub Pages** — privacy + acknowledgements à `aituglo.github.io/medity`

### Restant pour la prod

- **Tests UI** (purement V2)

---

## Lessons Learned (spécifiques au projet)

(Ajouter ici les pièges et corrections au fil du dev. Format : `[YYYY-MM-DD] CONTEXT → LESSON`)

- [2026-05-07] CONTEXT: Couleurs définies uniquement comme `static let` sur `Color` ne fonctionnent pas dans `.foregroundStyle(.ink)` car ce dernier attend un `ShapeStyle` → LESSON: Toujours dupliquer chaque token couleur dans une `extension ShapeStyle where Self == Color` pour permettre les usages `.foregroundStyle(.token)` / `.fill(.token)` sans qualifier.
- [2026-05-07] CONTEXT: Après ajout de `TimerRing.swift`, le build échoue avec "cannot find 'TimerRing' in scope" → LESSON: xcodegen liste explicitement les fichiers dans le pbxproj, il ne synchronise pas. Toujours `xcodegen generate` après création/suppression d'un fichier `.swift`.
