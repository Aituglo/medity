import SwiftUI

/// Full-width pill CTA used at the bottom of most flows.
///
/// Layout: label on the left, an icon-in-circle anchor on the right
/// (the design intentionally puts the icon trailing the verb).
struct PrimaryButton: View {
    enum IconKind {
        case play
        case arrow
    }

    let label: String
    let icon: IconKind
    let action: () -> Void

    init(_ label: String, icon: IconKind = .play, action: @escaping () -> Void) {
        self.label = label
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(label)
                    .font(Typography.body(size: 17, weight: .medium))
                    .foregroundStyle(.ink)
                    .tracking(0.2)
                IconView(kind: icon)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.ink.opacity(0.06)))
            }
            .frame(maxWidth: .infinity, minHeight: 64)
            .glassSurface(radius: Radius.button, tint: 0.40, interactive: true)
        }
        .buttonStyle(.plain)
    }
}

private struct IconView: View {
    let kind: PrimaryButton.IconKind

    var body: some View {
        switch kind {
        case .play:
            Triangle()
                .fill(Color.ink)
                .frame(width: 11, height: 12)
                .offset(x: 1)   // optical centering — the centroid sits left
        case .arrow:
            Image(systemName: "arrow.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.ink)
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

#Preview {
    ZStack {
        Backdrop(.dawn)
        VStack(spacing: 16) {
            PrimaryButton("Begin", icon: .play) {}
            PrimaryButton("Continue", icon: .arrow) {}
        }
        .padding()
    }
}
