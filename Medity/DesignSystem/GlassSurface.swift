import SwiftUI

/// Glass surface modifier — the recipe used for cards, buttons, pills, sheets.
///
/// Built on iOS 26's native Liquid Glass (`.glassEffect`) so surfaces pick up
/// real-time refraction, specular highlights, and content-aware tinting from
/// the system. Tint is applied via Glass's own `.tint(_:)` so the system can
/// blend it into the refraction model — covering the glass with a separate
/// opaque shape would just render a flat white card and erase the effect.
///
/// A 0.5 pt outer hairline reinforces the design's edge detail; the system
/// already paints a specular highlight on top so we don't need to add one.
struct GlassSurface: ViewModifier {
    var radius: CGFloat = Radius.card
    /// White tint blended into the glass.
    /// `0` = pure system glass, `0.20` ≈ default surfaces, `0.55` ≈ hero CTAs.
    /// Keep values low — Liquid Glass is meant to read as glass, not paint.
    var tint: Double = 0.20
    /// Whether the surface should respond to taps (slight scale + sheen ping).
    /// Set to `true` for tappable elements — buttons, chips, list rows.
    var interactive: Bool = false

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)
        return content
            .glassEffect(
                .regular
                    .tint(Color.white.opacity(tint))
                    .interactive(interactive),
                in: shape
            )
            .overlay {
                shape.strokeBorder(Color.hairline, lineWidth: 0.5)
            }
    }
}

extension View {
    /// Apply the Medity glass surface treatment.
    /// See ``GlassSurface`` for the layering recipe.
    func glassSurface(
        radius: CGFloat = Radius.card,
        tint: Double = 0.20,
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

            Text("Prominent (tint 0.40)")
                .font(Typography.body(size: 17, weight: .medium))
                .foregroundStyle(.ink)
                .padding(20)
                .glassSurface(tint: 0.40)

            Text("Hero (tint 0.55)")
                .font(Typography.body(size: 17, weight: .medium))
                .foregroundStyle(.ink)
                .padding(20)
                .glassSurface(tint: 0.55)

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
