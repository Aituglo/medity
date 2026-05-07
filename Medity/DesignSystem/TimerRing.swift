import SwiftUI

/// The signature dial of Medity — a circular timer slider.
///
/// Visually a clock-like ring of 60 tick marks with a gradient progress arc,
/// minute numerals at 0/15/30/45, and a luminous drag handle at the current
/// position. Drag anywhere on the ring to set duration.
///
/// Behavior:
/// - Drag maps the touch angle (clockwise from 12 o'clock) directly to minutes
///   in `range`. Outside the range it clamps; tapping at the top yields the
///   maximum (60), not zero.
/// - On idle (no drag, `isActive == false`), the whole ring breathes — a slow
///   1.0 ↔ 1.03 scale on a 4 s cycle. Pauses while the user is interacting or
///   when a session is running.
/// - Each minute change emits a selection haptic.
struct TimerRing: View {
    @Binding var minutes: Int
    var range: ClosedRange<Int> = 3...60
    var size: CGFloat = 350
    /// While `true`, no breathing pulse and the handle is hidden — the ring is
    /// in "session" mode and only displays remaining progress.
    var isActive: Bool = false

    @State private var isBreathing = false
    @GestureState private var isDragging = false

    /// Position on the ring expressed as a 0…1 fraction of the full revolution.
    private var progress: Double { Double(minutes) / 60.0 }

    /// Inner ring stroke radius (the geometric center of the track / arc).
    private var ringRadius: CGFloat { size / 2 - 18 }

    var body: some View {
        ZStack {
            centerDisc
            tickMarks
            track
            progressArc
            minuteNumerals
            if !isActive { handle }
        }
        .frame(width: size, height: size)
        .contentShape(Circle())
        .scaleEffect(isBreathing && !isActive && !isDragging ? 1.03 : 1.0)
        .gesture(dragGesture)
        .sensoryFeedback(.selection, trigger: minutes)
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                isBreathing = true
            }
        }
    }

    // MARK: - Layers

    /// Soft white glass disc filling the inside of the ring. Not interactive.
    private var centerDisc: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        .white.opacity(0.85),
                        .white.opacity(0.25),
                        .white.opacity(0)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: ringRadius
                )
            )
            .frame(width: ringRadius * 2 + 4, height: ringRadius * 2 + 4)
    }

    /// 60 tick marks. Major ticks (every 5) are longer + thicker. Past ticks
    /// (≤ progress) blend toward `accent`; future ones sit at low ink opacity.
    private var tickMarks: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            for i in 0..<60 {
                let isMajor = i.isMultiple(of: 5)
                let angle = (Double(i) / 60.0) * 2 * .pi - .pi / 2
                let inner = ringRadius - (isMajor ? 8 : 5)
                let outer = ringRadius + (isMajor ? 4 : 2)
                let p1 = CGPoint(
                    x: center.x + inner * cos(angle),
                    y: center.y + inner * sin(angle)
                )
                let p2 = CGPoint(
                    x: center.x + outer * cos(angle),
                    y: center.y + outer * sin(angle)
                )
                let passed = (Double(i) / 60.0) <= progress
                let color: Color = passed ? .accent : .ink
                let opacity: Double = passed
                    ? (isMajor ? 0.55 : 0.30)
                    : (isMajor ? 0.22 : 0.08)
                let width: CGFloat = isMajor ? 1.2 : 0.6

                var line = Path()
                line.move(to: p1)
                line.addLine(to: p2)
                context.stroke(
                    line,
                    with: .color(color.opacity(opacity)),
                    style: StrokeStyle(lineWidth: width, lineCap: .round)
                )
            }
        }
    }

    /// The faint full-circle track that the arc sits on.
    private var track: some View {
        Circle()
            .stroke(.hairline, lineWidth: 2)
            .frame(width: ringRadius * 2, height: ringRadius * 2)
    }

    /// Gradient arc showing how much of the dial is "active".
    private var progressArc: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(
                LinearGradient(
                    colors: [
                        Color(hex: 0x9DB7DB),
                        Color(hex: 0x6B8DBF),
                        Color(hex: 0x3D5F94)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
            .frame(width: ringRadius * 2, height: ringRadius * 2)
            .opacity(0.85)
    }

    /// "60 / 15 / 30 / 45" placed quarter-way around the ring.
    private var minuteNumerals: some View {
        ZStack {
            ForEach([0, 15, 30, 45], id: \.self) { m in
                let angle = (Double(m) / 60.0) * 2 * .pi - .pi / 2
                let r = ringRadius - 22
                let x = (size / 2) + r * cos(angle)
                let y = (size / 2) + r * sin(angle)
                Text(m == 0 ? "60" : "\(m)")
                    .font(Typography.body(size: 9, weight: .regular))
                    .tracking(1)
                    .foregroundStyle(.inkTertiary)
                    .position(x: x, y: y)
            }
        }
    }

    /// Handle: glow halo, white disc with hairline, accent dot, sheen.
    private var handle: some View {
        let angle = progress * 2 * .pi - .pi / 2
        let x = (size / 2) + ringRadius * cos(angle)
        let y = (size / 2) + ringRadius * sin(angle)
        return ZStack {
            // Glow halo
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.white, .white.opacity(0.4), .white.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: 20
                    )
                )
                .frame(width: 40, height: 40)

            // Outer soft disc
            Circle()
                .fill(.white)
                .frame(width: 26, height: 26)
                .overlay(Circle().stroke(.ink.opacity(0.10), lineWidth: 0.5))
                .shadow(color: .ink.opacity(0.10), radius: 4, x: 0, y: 1)

            // Accent dot
            Circle()
                .fill(.accent)
                .frame(width: 9, height: 9)

            // Center sheen offset
            Circle()
                .fill(.white.opacity(0.6))
                .frame(width: 2.4, height: 2.4)
                .offset(x: -1, y: -1.5)
        }
        .position(x: x, y: y)
    }

    // MARK: - Drag handling

    /// Maps a touch location (in the ring's local space) to a minute value.
    /// Top of the ring is the "60 / 0" anchor — tapping there yields 60, never
    /// 0, so the dial covers the full range without a dead zone.
    private func minutes(at location: CGPoint, center: CGPoint) -> Int {
        let dx = location.x - center.x
        let dy = location.y - center.y
        // atan2 in screen coords: clockwise positive, 3 o'clock = 0.
        // Shift so 12 o'clock = 0 and normalize to [0, 2π).
        let raw = atan2(dy, dx) + .pi / 2
        let normalized = raw < 0 ? raw + 2 * .pi : raw
        let progress = normalized / (2 * .pi)
        let snapped = Int((progress * 60).rounded())
        let value = snapped == 0 ? 60 : snapped
        return max(range.lowerBound, min(range.upperBound, value))
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($isDragging) { _, state, _ in state = true }
            .onChanged { value in
                let center = CGPoint(x: size / 2, y: size / 2)
                minutes = minutes(at: value.location, center: center)
            }
    }
}

// MARK: - Preview

#Preview("Idle") {
    @Previewable @State var minutes = 20
    ZStack {
        Backdrop(.dawn)
        AuraView(size: 440)
        TimerRing(minutes: $minutes)
    }
}

#Preview("Active session") {
    @Previewable @State var minutes = 20
    ZStack {
        Backdrop(.day)
        TimerRing(minutes: $minutes, isActive: true)
    }
}
