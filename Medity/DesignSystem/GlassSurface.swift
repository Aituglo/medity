import SwiftUI

/// Glass surface modifier — the recipe used for cards, buttons, pills, sheets.
///
/// Built on iOS 26's native Liquid Glass (`.glassEffect`) so surfaces pick up
/// real-time refraction, specular highlights, and content-aware tinting from
/// the system. We layer a soft white veil on top to bias the look toward our
/// brighter "monastic glass" palette and a 0.5 pt hairline border for the
/// crisp edge the design specifies.
struct GlassSurface: ViewModifier {
    var radius: CGFloat = Radius.card
    /// Extra white veil over the glass.
    /// `0` = pure system glass, `0.55` ≈ default cards, `0.85` ≈ hero CTAs.
    var tint: Double = 0.55
    /// Whether the surface should respond to taps (slight scale + highlight).
    /// Set to `true` for tappable elements — buttons, chips, list rows.
    var interactive: Bool = false

    func body(content: Content) -> some View {
        content
            .background {
                let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
                shape
                    .fill(Color.white.opacity(tint))
                    .glassEffect(
                        interactive ? .regular.interactive() : .regular,
                        in: shape
                    )
            }
            .overlay {
                // Crisp 0.5 pt hairline — the design's defining edge detail.
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Color.hairline, lineWidth: 0.5)
            }
    }
}

extension View {
    /// Apply the Medity glass surface treatment.
    /// See ``GlassSurface`` for the layering recipe.
    func glassSurface(
        radius: CGFloat = Radius.card,
        tint: Double = 0.55,
        interactive: Bool = false
    ) -> some View {
        modifier(GlassSurface(radius: radius, tint: tint, interactive: interactive))
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
                .glassSurface(radius: Radius.pill, tint: 0.55, interactive: true)
        }
        .padding()
    }
}
