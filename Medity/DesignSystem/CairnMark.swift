import SwiftUI

/// The Medity logo: three stacked organic stones (a zen cairn).
///
/// Path coordinates are taken directly from the SVG in the design prototype
/// (`CairnMark` in medity-screens-1.jsx, viewBox 80×84) and scaled to the
/// requested frame. Treating it as a `Shape` lets us tint, scale, and use it
/// in icon sizes without shipping a raster.
struct CairnMark: Shape {
    func path(in rect: CGRect) -> Path {
        // Source SVG viewBox is 80×84.
        let sx = rect.width  / 80.0
        let sy = rect.height / 84.0
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * sx, y: rect.minY + y * sy)
        }

        var path = Path()

        // Bottom stone — widest, rests on the ground line.
        path.move(to: p(8, 74))
        path.addCurve(to: p(24, 56), control1: p(6, 66),  control2: p(14, 58))
        path.addCurve(to: p(64, 60), control1: p(36, 54), control2: p(52, 56))
        path.addCurve(to: p(70, 76), control1: p(72, 62), control2: p(76, 70))
        path.addCurve(to: p(32, 81), control1: p(62, 82), control2: p(46, 82))
        path.addCurve(to: p(8, 74),  control1: p(20, 80), control2: p(10, 80))
        path.closeSubpath()

        // Middle stone.
        path.move(to: p(18, 50))
        path.addCurve(to: p(34, 35), control1: p(16, 42), control2: p(24, 36))
        path.addCurve(to: p(60, 44), control1: p(46, 34), control2: p(56, 38))
        path.addCurve(to: p(44, 54), control1: p(64, 50), control2: p(56, 54))
        path.addCurve(to: p(18, 50), control1: p(32, 54), control2: p(20, 54))
        path.closeSubpath()

        // Top stone — small ellipse, slightly off-center to feel hand-stacked.
        let topRect = CGRect(
            x: rect.minX + (42 - 12) * sx,
            y: rect.minY + (26 - 7.5) * sy,
            width:  24 * sx,
            height: 15 * sy
        )
        path.addEllipse(in: topRect)

        return path
    }
}

#Preview {
    ZStack {
        Backdrop(.dawn)
        CairnMark()
            .fill(Color.ink)
            .frame(width: 80, height: 84)
    }
}
