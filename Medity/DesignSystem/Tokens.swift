import SwiftUI

// MARK: - Color tokens
//
// Single source of truth: design/DESIGN_SYSTEM.md.
// All values come from the Claude Design prototype (medity-primitives.jsx).
// Light mode only in V1 — no dynamic color sets.

extension Color {
    /// Page background (`#F4F6F9`).
    static let appBackground = Color(hex: 0xF4F6F9)

    // Ink scale — primary text down to captions.
    static let ink          = Color(hex: 0x0F1B2D)
    static let inkSecondary = Color(hex: 0x6B7891)
    static let inkTertiary  = Color(hex: 0xA8B0BF)

    // Cool dusty blue accent — chrome, links, progress arcs.
    static let accent = Color(hex: 0x4A6FA5)

    // Warm clay — reserved for celebration moments (streak flame, achievement unlock).
    static let warmAccent     = Color(hex: 0xC68B5C)
    static let warmAccentSoft = Color(hex: 0xE8C9A8)

    /// Soft blue glow used as the radial aura behind the timer.
    static let aura = Color(hex: 0xC9D6E8)

    // Hairlines — derived from ink, transparent.
    static let hairline       = Color(hex: 0x0F1B2D, opacity: 0.06)
    static let hairlineStrong = Color(hex: 0x0F1B2D, opacity: 0.10)
}

// MARK: - Typography

enum Typography {
    /// Base sans-serif family. Falls back to system if Geist isn't bundled.
    /// Geist isn't shipped in V1; system + a tight tracking + light weights
    /// approximates the design closely enough on iOS 18+.
    static let family = "Geist"

    static func display(size: CGFloat, weight: Font.Weight = .thin) -> Font {
        .custom(family, size: size, relativeTo: .largeTitle)
            .weight(weight)
    }

    static func body(size: CGFloat = 16, weight: Font.Weight = .regular) -> Font {
        .custom(family, size: size, relativeTo: .body)
            .weight(weight)
    }

    /// Used for caps eyebrow labels — small, wide-tracked, uppercase at call site.
    static func eyebrow(size: CGFloat = 11) -> Font {
        .custom(family, size: size, relativeTo: .caption2)
            .weight(.medium)
    }
}

// MARK: - Geometry

enum Radius {
    static let pill: CGFloat   = 9999    // semantic — applies an .infinity-corner.
    static let card: CGFloat   = 24
    static let chip: CGFloat   = 20
    static let row: CGFloat    = 20
    static let button: CGFloat = 9999
}

enum Spacing {
    static let xs: CGFloat = 4
    static let s:  CGFloat = 8
    static let m:  CGFloat = 14
    static let l:  CGFloat = 18
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 36
}

// MARK: - Hex initializer

extension Color {
    /// `Color(hex: 0x4A6FA5)` reads more directly than three CGFloat divisions.
    init(hex: UInt32, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8)  & 0xFF) / 255.0
        let b = Double( hex        & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}
