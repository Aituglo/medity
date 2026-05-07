import SwiftUI

/// Soft radial glow used behind the timer ring and other focal elements.
///
/// Translates `MAura` from the design prototype: a circular radial gradient
/// fading to transparent, then heavily blurred so the edges feel like light,
/// not shape.
struct AuraView: View {
    var size: CGFloat = 360
    var hue: Color = .aura
    var intensity: Double = 1.0

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        hue,
                        hue.opacity(0.53),
                        hue.opacity(0)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: size / 2
                )
            )
            .frame(width: size, height: size)
            .blur(radius: 40)
            .opacity(0.75 * intensity)
            .allowsHitTesting(false)
    }
}

#Preview {
    ZStack {
        Backdrop(.dawn)
        AuraView(size: 420)
    }
}
