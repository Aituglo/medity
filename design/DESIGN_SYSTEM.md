# Medity — Design System Reference

Source of truth: the JSX prototype in this folder. This doc extracts the **tokens, components, screens, motion & audio** in a form usable while writing SwiftUI.

> The HTML/JSX files are a prototype — recreate them visually in SwiftUI, don't port them structurally.

---

## 1. Color tokens

Light mode only. Cool neutral blues, warm clay accent for celebration moments.

| Token       | Hex / value                  | Usage                                       |
|-------------|------------------------------|---------------------------------------------|
| `bg`        | `#F4F6F9`                    | App background base                         |
| `ink`       | `#0F1B2D`                    | Primary text, big numerals                  |
| `ink2`      | `#6B7891`                    | Secondary text                              |
| `ink3`      | `#A8B0BF`                    | Tertiary text, captions, eyebrow labels     |
| `accent`    | `#4A6FA5`                    | Primary accent (dusty blue) — chrome, links |
| `warm`      | `#C68B5C`                    | Celebration accent (streak flame, unlocks)  |
| `warmSoft`  | `#E8C9A8`                    | Soft warm aura                              |
| `aura`      | `#C9D6E8`                    | Aura / glow gradient stop                   |
| `hairline`  | `rgba(15,27,45,0.06)`        | Subtle dividers                             |
| `hairline2` | `rgba(15,27,45,0.10)`        | Stronger dividers, dashed borders           |
| `glass`     | `rgba(255,255,255,0.55)`     | Default glass tint                          |
| `glassDeep` | `rgba(255,255,255,0.72)`     | Deeper glass for prominent surfaces         |

### Backdrop moods (radial gradient blends)

The whole-screen ambient backdrop uses 3 stacked radials over `bg`. Mood shifts the tint:

- **dawn** — `#EAE2E8` / `#E4ECF5` / `#F4F6F9` (default, slightly warm)
- **day**  — `#E4ECF5` / `#EFF3F8` / `#F4F6F9` (cleanest, used during session)
- **dusk** — `#E8E6F0` / `#E2E8F0` / `#F0F2F7` (paywall, widgets-on-wallpaper)
- **night**— `#DDE3EE` / `#E5EAF2` / `#EEF1F6` (reserved)

### Heatmap fill scale

5 levels for the 6-month practice heatmap:
1. `rgba(15,27,45,0.05)` — empty
2. `rgba(74,111,165,0.18)`
3. `rgba(74,111,165,0.36)`
4. `rgba(74,111,165,0.58)`
5. `rgba(74,111,165,0.85)` — peak

---

## 2. Typography

Single family (per the chat: "user prefers sans across the board"):

- **Family**: `Geist` (Google Fonts). Fallback: SF Pro / system. In SwiftUI ship Geist as a custom font; fall back to `.system(design: .default)`.
- **Display weight**: 200 (thin), tight tracking. Used for big numerals (timer, streak count, "20 min").
- **Heading**: 300–400, letter-spacing -0.5
- **UI**: 500–600, tabular-nums for the countdown (`.monospacedDigit()` in SwiftUI)
- **Eyebrow / caps labels**: 10.5–11px, letter-spacing 2–3, uppercase, color `ink3`

### Type scale (px)

| Role                  | Size  | Weight | Tracking |
|-----------------------|-------|--------|----------|
| Hero numeral (timer)  | 96–132| 200    | -2 to -5 |
| Streak hero (stats)   | 88    | 200    | -3       |
| Display (titles)      | 38–60 | 200–300| -0.5 to -1.5 |
| Section title         | 26–30 | 400    | -0.3     |
| Body                  | 15–17 | 400    | -0.1     |
| Secondary             | 13–14 | 400    | 0        |
| Caps eyebrow          | 10.5–11| 500   | +2.5–3   |

> Italic style is used sparingly for poetic captions ("Day twelve, streak unbroken"). Geist doesn't ship italic — use a light oblique skew or accept upright.

---

## 3. Core components

These map directly to SwiftUI views. Names are suggestions for the iOS codebase.

### `MGlass` → `GlassSurface`
```
radius: 24 (default), 9999 for pills
tint: 0.55 default, 0.72 for deeper, 0.85 for hero CTA
blur: 40 (heavy), 20–30 for chips/pills
border: 0.5px solid rgba(255,255,255,0.6)
shadow:
  - inset 0 1px 0 rgba(255,255,255,0.7)
  - inset 0 -1px 0 rgba(15,27,45,0.04)
  - 0 1px 1px rgba(15,27,45,0.025)
  - 0 8px 24px rgba(15,27,45,0.04)
hairline: outer 0.5px ring at rgba(15,27,45,0.06)
```
SwiftUI: `.background(.ultraThinMaterial)` with overlay strokes + `.shadow()` stack. May need a custom `Material` because iOS materials adapt to wallpaper — we want a stable look.

### `MAura` → `AuraView`
Soft radial gradient circle, blurred. `radial-gradient(circle, hue 0%, hue@53% 35%, transparent 70%)`, blur 40px, opacity 0.75.

### `MPrimaryButton` → `PrimaryButton`
- Full-width pill, 64px tall, glass tint 0.65, blur 40
- Label (size 17, weight 500, +0.2 tracking) + 36px circle behind icon (`play` or `arrow`), bg `rgba(15,27,45,0.06)`
- The icon is on the **right**, label on the left of the icon

### `MPill` → `Pill`
Inline glass pill, padding 12×18, used for stats hero icons + chips.

### `TimerRing` → `TimerRingView` (key custom view)
SVG layered ring at size 350. From outer to inner:
1. Glass-filled center disc (`url(#ringbg)` radial gradient, white→transparent)
2. Hairline at `r+10`, `rgba(15,27,45,0.05)`
3. Track circle at `r`, stroke `rgba(15,27,45,0.06)` width 2
4. **60 tick marks**: each 6° around the ring. Major (every 5) longer + thicker. Past ticks (≤ progress) blend toward `accent`; future ticks at low opacity.
5. Progress arc: gradient stroke `#9DB7DB → #6B8DBF → #3D5F94`, stroke 2.5, dash `(progress*circ, circ)`, rotated -90°, opacity 0.85
6. Minute numerals at 0/15/30/45 (font 9, tracking 1, color `ink3`)
7. Drag handle: glow halo (r=20), white disc with hairline (r=13), accent dot (r=4.5), small white sheen (r=1.2 offset)

Implement in SwiftUI with `Canvas` or composed `Shape`s. The ring is the dial — drag updates `value` (3–60 minutes). On idle, breathing pulse: scale 1.0 → 1.03 over 4s ease-in-out, infinite.

### Heatmap
26 weeks × 7 days. Cell 11.6×11.6, gap 3, radius 2.5. Colors per scale above.

### `Segmented`
Glass pill container, padding 4, gap 2. Active option: white bg, soft shadow, `ink` text. Inactive: transparent, `ink2` text.

### iOS Toggle
51×31 pill. On: `accent` bg. Off: `rgba(15,27,45,0.12)`. Thumb: 27×27 white, shadow `0 2px 4px rgba(0,0,0,0.15)`. Just use SwiftUI `Toggle` with `.tint(.accent)` — close enough.

### List row (settings)
Padding 14×18, separator `0.5px hairline`, label 16px ink, detail 15px ink2, chevron from `Icons.chevron`. Group cards: glass radius 20, margin 0×14, with optional uppercase header above and footer caption below.

### Status bar / Dynamic Island / Home indicator
For SwiftUI we get these for free from the OS. The mocks include them visually only because it's a prototype.

---

## 4. Screen inventory

12 main + 2 extras. All 393×852 (iPhone 16 Pro).

| #   | Name                       | File                       | Mood   | Purpose                                  |
|-----|----------------------------|----------------------------|--------|------------------------------------------|
| 01  | Onboarding · Brand         | medity-screens-1.jsx       | dawn   | Cairn logo + "Medity" + tagline          |
| 02  | Onboarding · Features      | medity-screens-1.jsx       | day    | "Three simple things" — Timer/Sounds/Stats |
| 03  | Onboarding · Permissions   | medity-improvements.jsx (`v2`) | dawn  | Single illustrated card, Health + Reminders |
| 04  | **Home / Timer setup**     | medity-screens-1.jsx       | dawn   | Ring dial, presets, sound+bells pills, primary CTA |
| 05  | **Session in progress**    | medity-screens-2.jsx       | day    | Big mm:ss countdown, mist particles, pause |
| 06  | Session complete           | medity-screens-2.jsx       | day    | "Well done." + 4-stat summary card        |
| 07  | Sound library              | medity-screens-2.jsx       | dawn   | Bottom sheet, sectioned list, Plus upsell |
| 08  | Bells picker               | medity-screens-2.jsx       | dawn   | Bell sound list + interval segmented      |
| 09  | Stats · Practice           | medity-screens-3.jsx       | day    | Streak hero, heatmap, 2x2 metrics, line graph |
| 09a | Stats · First day (empty)  | medity-improvements.jsx    | dawn   | "The first stone." — empty state           |
| 10  | Achievements (Markers)     | medity-screens-3.jsx       | day    | 3-col grid of badges                       |
| 10a | Achievement detail sheet   | medity-improvements.jsx    | day    | Focused unlock view + "up next"            |
| 11  | Settings                   | medity-extras.jsx          | day    | Grouped list — Reminder/Defaults/Health/Plus/About |
| 12  | Paywall (Medity Plus)      | medity-extras.jsx          | dusk   | "Go deeper." benefits + €14.99 once       |
| —   | Widgets preview            | medity-extras2.jsx         | dusk   | Small / Medium / Large + Lock screen      |
| —   | Live Activity / Dyn Island | medity-extras2.jsx         | dusk   | Compact / Minimal / Expanded states       |
| —   | Style guide (canvas)       | medity-extras2.jsx         | dawn   | Color, type, components reference          |
| —   | Sound & touch (canvas)     | medity-improvements.jsx    | day    | Bell envelopes, ducking curve, haptics    |
| —   | App icon                   | medity-extras3.jsx         | dawn   | Cairn motif, soft blue radial gradient    |

---

## 5. Brand mark — the cairn

Three stacked organic stones (zen cairn). Path data lives in `CairnMark` (medity-screens-1.jsx:30).

App icon background:
```
radial-gradient(circle at 30% 25%,
  #F2F5FA 0%, #D7E1EF 35%, #B5C6DD 70%, #94AAC8 100%)
```
Inner glow: `radial-gradient(circle, rgba(255,255,255,0.6), transparent 70%)` inset 24px.
Stones in `ink` (#0F1B2D). No wordmark on the icon.

For SwiftUI: vectorize the cairn as a `Shape` or ship as PDF/SVG asset. Reuse on onboarding screen 01, app icon, paywall hero, empty state.

---

## 6. Motion

| Element                  | Behavior                                                    |
|--------------------------|-------------------------------------------------------------|
| Timer ring (idle)        | Breathing pulse — scale 1.0 ↔ 1.03 over 4s, ease-in-out, ∞ |
| Timer ring (active)      | Static; arc shrinks linearly with remaining time            |
| Session particles        | ~22 dots, accent color, drift upward slowly                 |
| Background hue           | Subtle drift across session length (dawn → day)             |
| Numerals (countdown)     | Crossfade — never tick visibly. Use `.contentTransition(.numericText())` |
| Glass surfaces (host)    | Subtle parallax with device tilt (CoreMotion)               |
| Bell ducking             | Sound dips -6 dB over 600 ms, holds, returns over 1.2 s     |
| Begin button             | On tap: ring fades into session screen, breathing slows     |

---

## 7. Audio & haptics language

(See the "Sound & touch" canvas in `medity-improvements.jsx`.)

### Bell timbres (start / end / interval)
| Name           | Decay | Character          |
|----------------|-------|--------------------|
| Tibetan bowl   | 8 s   | Resonant, warm     |
| Japanese bell  | 5 s   | Bright, clean      |
| Gong           | long  | Deep, lingering    |
| Soft chime     | 2.5 s | Quiet, near        |
| Deep bell      | long  | Long decay         |
| Wood block     | dry   | Percussive         |

### Background sounds
- **Nature**: Rain · Light, Rain · Heavy, Ocean Waves, Ocean Shore, Forest, River, Fire, Wind
- **Noise**: Brown, Pink, White
- **Sacred** (Plus): Tibetan Bowls, Om Chant, Temple Ambience
- **Stillness**: Silence

All loop seamlessly. Crossfade 200 ms on play/pause.

### Haptics
| Trigger        | Pattern                                |
|----------------|----------------------------------------|
| Begin          | Soft tap, then a longer "breath" pulse |
| Bell interval  | Two whisper taps                       |
| Complete       | Three soft pulses, half-second apart   |
| Pause / Resume | Single soft tap                        |

SwiftUI: `UIImpactFeedbackGenerator(style: .soft)` for taps, `CHHapticEngine` for the breath/whisper patterns.

---

## 8. Microcopy direction

Quiet, literary, lower-case verbs, no exclamation marks. Examples:

- "A quieter mind, daily."
- "Begin a session"
- "20 min session"
- "Drag the dial"
- "Well done."
- "Day 12 · streak unbroken"
- "The first stone."
- "Quietly, with your permission."
- "Allow & begin"
- "Skip for now"
- "Go deeper." (paywall)
- "Unlock — €14.99 once"
- "Restore purchase"

---

## 9. SwiftUI mapping cheatsheet

| Web concept                 | SwiftUI equivalent                                              |
|-----------------------------|------------------------------------------------------------------|
| `MGlass` (glass surface)    | Custom view with `.ultraThinMaterial` + overlay borders + shadow |
| `MBackdrop` (auras)         | `ZStack` with stacked `RadialGradient`s                          |
| `MAura`                     | `Circle().fill(RadialGradient(...)).blur(40)`                    |
| `TimerRing`                 | `Canvas` or composed `Shape`s + `.gesture(DragGesture())`        |
| `Heatmap`                   | `LazyVGrid` of `RoundedRectangle`s                               |
| `Segmented`                 | Custom — wrap `Picker(.segmented)` doesn't match the glass look |
| Sound library sheet         | `.sheet { ... }` with `.presentationDetents([.large])`           |
| Dynamic Island              | `ActivityKit` + Live Activity widget                             |
| Widgets                     | `WidgetKit` extension target                                     |
| Particles (session mist)    | `TimelineView(.animation)` over a `Canvas`                       |
| Big crossfading numerals    | `Text("\(time)").contentTransition(.numericText())`              |
| HealthKit Mindful Minutes   | `HKCategoryTypeIdentifier.mindfulSession`                        |
| iCloud sync                 | SwiftData with `ModelConfiguration(cloudKitDatabase: .private)`  |

---

## 10. Files in this folder

- `Medity.html` — entry HTML (loads all JSX via Babel-standalone in browser)
- `ios-frame.jsx` — generic iOS frame primitives (status bar, list row) — partly superseded by `medity-primitives.jsx`
- `medity-primitives.jsx` — **tokens + core components** (M, MGlass, MBackdrop, MAura, MPhone, MPrimaryButton, Icons)
- `medity-screens-1.jsx` — Onboarding 1-2-3 + Home + `TimerRing` + `CairnMark`
- `medity-screens-2.jsx` — Session, Complete, Sound library, Bells
- `medity-screens-3.jsx` — Stats (+ Heatmap, MetricTile, LineGraph) + Achievements (+ Badge, BadgeIcon)
- `medity-extras.jsx` — Settings, Paywall, Widgets (Small/Medium/Large/Lock)
- `medity-extras2.jsx` — `ScreenWidgets` page, `ScreenLiveActivity` + `MiniRing`, Style guide
- `medity-extras3.jsx` — Style guide helpers, `ScreenAppIcon`, the `App` mount (canvas root)
- `medity-improvements.jsx` — `ScreenStatsEmpty`, `ScreenAchievementDetail`, `ScreenOnboarding3v2`, `ScreenAudioHaptic` + Bell/Duck/Haptic visualizers
- `design-canvas.jsx` — Figma-ish viewport wrapper (pan/zoom canvas) — **not relevant for the iOS port**
- `medity-app.jsx` — the original (now-superseded) canvas mount
- `HANDOFF.md` — original handoff notes from Claude Design
- `chat-history.md` — full transcript of the design iteration
