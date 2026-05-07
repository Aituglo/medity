import Foundation

/// Static catalog of bell timbres available for the start / end / interval
/// chimes during a session. Each entry is either a bundled audio file (for
/// recordings) or a `BellSynth.Preset` (for synthesized partials).
///
/// Identifiers are stable strings, persisted on
/// `UserPreferences.defaultBellIdentifier`.
enum BellCatalog {

    enum Kind: Hashable {
        /// Bundled audio file in `Resources/Sounds/<name>.{caf,m4a,mp3,wav}`.
        case file(name: String)
        /// Procedurally synthesized bell with a specific partial profile.
        case synth(BellSynth.Preset)
    }

    struct Bell: Identifiable, Hashable {
        let id: String
        let displayName: String
        /// Short character description ("Resonant, warm", "Bright, clean").
        let subtitle: String
        let kind: Kind
    }

    static let all: [Bell] = [
        Bell(id: "tibetan-bowl",   displayName: "Tibetan Bowl",   subtitle: "Resonant, warm",      kind: .synth(.tibetanBowl)),
        Bell(id: "japanese-bell",  displayName: "Japanese Bell",  subtitle: "Bright, clean",       kind: .synth(.japaneseBell)),
        Bell(id: "soft-chime",     displayName: "Soft Chime",     subtitle: "Quiet, near",         kind: .synth(.softChime)),
        Bell(id: "deep-bell",      displayName: "Deep Bell",      subtitle: "Long decay",          kind: .synth(.deepBell)),
        Bell(id: "meditation-gong", displayName: "Meditation Gong", subtitle: "Soft, recorded",     kind: .file(name: "bell")),
    ]

    /// O(n) lookup. The catalog is small enough that this stays trivial.
    static func bell(for id: String) -> Bell? {
        all.first { $0.id == id }
    }

    /// Allowed interval-bell choices, in minutes. `nil` means "off".
    static let intervalChoices: [Int?] = [nil, 5, 10, 15]
}
