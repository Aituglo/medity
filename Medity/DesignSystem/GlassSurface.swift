import SwiftUI

/// Glass surface modifier — the recipe used for cards, buttons, pills, sheets.
///
/// Built on iOS 26's native Liquid Glass (`.glassEffect`) so surfaces pick up
/// real-time refraction, specular highlights, and content-aware tinting from
/// the system. We add two things on top:
///
///   1. A 0.5 pt outer hairline — the design's defining edge detail.
///   2. A two-layer ambient shadow — a tight contact shadow + a diffuse one.
///
/// Liquid Glass blends with whatever is behind it, so on a uniform backdrop
/// (like our `.dawn` page) the surface alone reads as "the same color as the
/// page". The hairline and shadow do the lifting that the refraction can't
/// when the backdrop has nothing to refract.
struct GlassSurface: ViewModifier {
    var radius: CGFloat = Radius.card
    /// White tint blended into the glass.
    /// `0` = pure system glass (default), `0.30` ≈ secondary CTAs, `0.50`+ ≈ hero.
    /// Keep values low — Liquid Glass is meant to read as glass, not paint.
    var tint: Double = 0
    /// Whether the surface should respond to taps with the system's interactive
    /// glass animation. Set to `true` for tappable elements.
    var interactive: Bool = false

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        return content
            .glassEffect(glass, in: shape)
            .overlay {
                shape.strokeBorder(.hairlineStrong, lineWidth: 0.5)
            }
            .shadow(color: .ink.opacity(0.05), radius: 1, x: 0, y: 1)
            .shadow(color: .ink.opacity(0.06), radius: 14, x: 0, y: 6)
    }

    /// Builds the configured `Glass` value, skipping `.tint(_:)` when zero so
    /// the system can apply its untinted refraction without an alpha-zero color
    /// nudge.
    private var glass: Glass {
        var g: Glass = .regular
        if tint > 0 {
            g = g.tint(.white.opacity(tint))
        }
        if interactive {
            g = g.interactive()
        }
        return g
    }
}

extension View {
    /// Apply the Medity glass surface treatment.
    /// See ``GlassSurface`` for the layering recipe.
    func glassSurface(
        radius: CGFloat = Radius.card,
        tint: Double = 0,
        interactive: Bool = false
    ) -> some View {
        modifier(GlassSurface(radius: radius, tint: tint, interactive: interactive))
    }
}

#Preview {
    ZStack {
        Backdrop(.dawn)
        VStack(spacing: 16) {
            Text("Default — pure glass")
                .font(Typography.body(size: 17, weight: .medium))
                .foregroundStyle(.ink)
                .padding(20)
                .glassSurface()

            Text("Tint 0.30 — secondary")
                .font(Typography.body(size: 17, weight: .medium))
                .foregroundStyle(.ink)
                .padding(20)
                .glassSurface(tint: 0.30)

            Text("Tint 0.50 — hero")
                .font(Typography.body(size: 17, weight: .medium))
                .foregroundStyle(.ink)
                .padding(20)
                .glassSurface(tint: 0.50)

            Text("Pill — interactive")
                .font(Typography.body(size: 14, weight: .medium))
                .foregroundStyle(.ink)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .glassSurface(radius: Radius.pill, interactive: true)
        }
        .padding()
    }
}
