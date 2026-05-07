import Foundation

/// Static catalog of every sound the app knows about — including the ones
/// gated behind Medity Plus.
///
/// Identifiers are stable strings (`"rain.light"`) so they can persist
/// safely on `UserPreferences.defaultSoundIdentifier` even as new sounds
/// are added or display names change. A `nil` identifier means "Silence"
/// is selected.
enum SoundCatalog {

    enum Category: String, CaseIterable {
        case nature    = "Nature"
        case noise     = "Noise"
        case sacred    = "Sacred"
        case stillness = "Stillness"
    }

    struct Sound: Identifiable, Hashable {
        /// Stable identifier — persisted, never localized.
        let id: String
        /// User-facing label (display only — never used as a key).
        let displayName: String
        let category: Category
        /// `true` when the sound is part of the Medity Plus IAP.
        let isPremium: Bool
        /// Bundle resource name (without extension) for the looping asset.
        /// `nil` means the sound is procedural (noise) or silent.
        let fileName: String?
    }

    /// All sounds, in the order they should appear inside their section.
    static let all: [Sound] = [
        // Nature
        Sound(id: "rain.light",   displayName: "Rain · Light",  category: .nature,    isPremium: false, fileName: "rain-light"),
        Sound(id: "rain.heavy",   displayName: "Rain · Heavy",  category: .nature,    isPremium: false, fileName: "rain-heavy"),
        Sound(id: "ocean.waves",  displayName: "Ocean Waves",   category: .nature,    isPremium: false, fileName: "ocean-waves"),
        Sound(id: "ocean.shore",  displayName: "Ocean Shore",   category: .nature,    isPremium: false, fileName: "ocean-shore"),
        Sound(id: "forest",       displayName: "Forest",        category: .nature,    isPremium: false, fileName: "forest"),
        Sound(id: "river",        displayName: "River",         category: .nature,    isPremium: false, fileName: "river"),
        Sound(id: "fire",         displayName: "Fire",          category: .nature,    isPremium: true,  fileName: "fire"),
        Sound(id: "wind",         displayName: "Wind",          category: .nature,    isPremium: true,  fileName: "wind"),

        // Noise — generated procedurally, no bundled file.
        Sound(id: "noise.brown",  displayName: "Brown",         category: .noise,     isPremium: false, fileName: nil),
        Sound(id: "noise.pink",   displayName: "Pink",          category: .noise,     isPremium: false, fileName: nil),
        Sound(id: "noise.white",  displayName: "White",         category: .noise,     isPremium: false, fileName: nil),

        // Sacred — Plus-only.
        Sound(id: "tibetan-bowls", displayName: "Tibetan Bowls",     category: .sacred, isPremium: true, fileName: "tibetan-bowls"),
        Sound(id: "om-chant",      displayName: "Om Chant",          category: .sacred, isPremium: true, fileName: "om-chant"),
        Sound(id: "temple",        displayName: "Temple Ambience",   category: .sacred, isPremium: true, fileName: "temple"),

        // Stillness — sentinel, no playback.
        Sound(id: "silence",       displayName: "Silence",           category: .stillness, isPremium: false, fileName: nil),
    ]

    /// O(n) lookup by identifier. The catalog is small enough that this
    /// stays trivial even on a hot path.
    static func sound(for id: String) -> Sound? {
        all.first { $0.id == id }
    }

    static func sounds(in category: Category) -> [Sound] {
        all.filter { $0.category == category }
    }
}
