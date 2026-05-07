import SwiftUI

/// Ambient page backdrop — three stacked radial gradients on top of `appBackground`.
///
/// Mirrors `MBackdrop` from the design prototype (medity-primitives.jsx).
/// Mood subtly shifts the tint of the gradient layers without ever leaving
/// the light-mode palette.
struct Backdrop: View {
    enum Mood {
        case dawn   // default, slightly warm
        case day    // cleanest, used during the active session
        case dusk   // paywall, "going-deeper" moments
        case night  // reserved for future themes

        var tints: (a: Color, b: Color, c: Color) {
            switch self {
            case .dawn:  return (Color(hex: 0xEAE2E8), Color(hex: 0xE4ECF5), Color(hex: 0xF4F6F9))
            case .day:   return (Color(hex: 0xE4ECF5), Color(hex: 0xEFF3F8), Color(hex: 0xF4F6F9))
            case .dusk:  return (Color(hex: 0xE8E6F0), Color(hex: 0xE2E8F0), Color(hex: 0xF0F2F7))
            case .night: return (Color(hex: 0xDDE3EE), Color(hex: 0xE5EAF2), Color(hex: 0xEEF1F6))
            }
        }
    }

    let mood: Mood

    init(_ mood: Mood = .dawn) {
        self.mood = mood
    }

    var body: some View {
        let t = mood.tints
        ZStack {
            t.c
            // Top-left warm wash.
            radial(t.a, center: UnitPoint(x: 0.18, y: 0.08), scale: 1.2)
            // Right shoulder wash.
            radial(t.b, center: UnitPoint(x: 0.88, y: 0.24), scale: 1.1)
            // Bottom uplift — the screen "breathes" from below.
            radial(t.b, center: UnitPoint(x: 0.50, y: 1.10), scale: 1.4)
        }
        .ignoresSafeArea()
    }

    private func radial(_ color: Color, center: UnitPoint, scale: CGFloat) -> some View {
        GeometryReader { geo in
            let maxDimension = max(geo.size.width, geo.size.height)
            RadialGradient(
                colors: [color, color.opacity(0)],
                center: center,
                startRadius: 0,
                endRadius: maxDimension * scale * 0.7
            )
        }
    }
}

#Preview("Dawn")  { Backdrop(.dawn) }
#Preview("Day")   { Backdrop(.day) }
#Preview("Dusk")  { Backdrop(.dusk) }
