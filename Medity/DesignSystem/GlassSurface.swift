import SwiftUI

/// Glass surface modifier — the recipe used for cards, buttons, pills, sheets.
///
/// Stacks (in order, back to front):
///   1. an `.ultraThinMaterial` background, optionally tinted whiter for prominence
///   2. an inner top highlight (sheen)
///   3. an inner bottom hairline (gravity)
///   4. a 0.5pt outer hairline border
///   5. an outer ambient shadow
///
/// This roughly mirrors the recipe in `MGlass` (medity-primitives.jsx). Native
/// `.ultraThinMaterial` already adapts blur strength to context, so we don't
/// expose a `blur` knob — only `tint` (how much extra white we layer on top)
/// and `radius`.
struct GlassSurface: ViewModifier {
    var radius: CGFloat = Radius.card
    /// Extra white veil over the material. 0 = pure system material,
    /// 0.55 ≈ default cards, 0.85 ≈ hero CTAs.
    var tint: Double = 0.55

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // System material — provides the actual blur.
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(.ultraThinMaterial)

                    // White veil — lifts the surface toward the design's
                    // brighter glass look (the system material reads grayer
                    // on a colorful backdrop than the prototype's flat tint).
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .fill(Color.white.opacity(tint))

                    // Inner top highlight — the "sheen" that sells the glass.
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .stroke(Color.white.opacity(0.7), lineWidth: 1)
                        .blur(radius: 0.5)
                        .mask(
                            RoundedRectangle(cornerRadius: radius, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [.white, .clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                        )
                }
            )
            .overlay(
                // Crisp 0.5pt hairline border — the design's defining edge detail.
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Color.hairline, lineWidth: 0.5)
            )
            .shadow(color: Color.ink.opacity(0.025), radius: 1, x: 0, y: 1)
            .shadow(color: Color.ink.opacity(0.04),  radius: 24, x: 0, y: 8)
    }
}

extension View {
    /// Apply the Medity glass surface treatment.
    /// See `GlassSurface` for the layering recipe.
    func glassSurface(radius: CGFloat = Radius.card, tint: Double = 0.55) -> some View {
        modifier(GlassSurface(radius: radius, tint: tint))
    }
}

#Preview {
    ZStack {
        Backdrop(.dawn)
        VStack(spacing: 16) {
            Text("Default glass card")
                .font(Typography.body(size: 17, weight: .medium))
                .foregroundStyle(.ink)
                .padding(20)
                .glassSurface()

            Text("Prominent (tint 0.85)")
                .font(Typography.body(size: 17, weight: .medium))
                .foregroundStyle(.ink)
                .padding(20)
                .glassSurface(tint: 0.85)

            Text("Pill")
                .font(Typography.body(size: 14, weight: .medium))
                .foregroundStyle(.ink)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .glassSurface(radius: Radius.pill, tint: 0.55)
        }
        .padding()
    }
}
