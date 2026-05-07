import SwiftUI

/// Home screen — the timer setup surface.
///
/// Layout (top → bottom):
///   1. Top bar — settings on the left, streak pill + stats on the right
///   2. Timer ring with the chosen duration in big serif numerals + caption
///   3. Horizontal preset chips (3, 5, 10, 15, 20, 30, 45, 60)
///   4. Sound + Bells labeled pills
///   5. Begin CTA
struct HomeView: View {
    /// Presets shown as chips. The currently-selected duration is highlighted
    /// when it matches one of these values exactly.
    private let presets = [3, 5, 10, 15, 20, 30, 45, 60]

    // V1 wiring: local @State. Will be lifted into a HomeViewModel + persisted
    // user preferences (SwiftData) once the persistence layer lands.
    @State private var minutes: Int = 20
    @State private var soundName: String = "Rain · Light"
    @State private var bellsSummary: String = "Start & End"
    @State private var streak: Int = 12

    var body: some View {
        ZStack {
            Backdrop(.dawn)

            VStack(spacing: 0) {
                HomeTopBar(streak: streak)
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                Spacer(minLength: 0)

                ZStack {
                    AuraView(size: 440)
                    TimerRing(minutes: $minutes)
                    timerLabel
                }

                presetRow
                    .padding(.top, 20)

                soundAndBellsRow
                    .padding(.top, 18)
                    .padding(.horizontal, 24)

                Spacer(minLength: 0)

                PrimaryButton("\(minutes) min session", icon: .play) {
                    // Hooked up when SessionView lands.
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
        }
    }

    // MARK: - Pieces

    /// The big duration readout at the center of the timer ring.
    private var timerLabel: some View {
        VStack(spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("\(minutes)")
                    .font(Typography.display(size: 132, weight: .thin))
                    .tracking(-5)
                    .foregroundStyle(.ink)
                    .contentTransition(.numericText())
                Text("min")
                    .font(Typography.body(size: 19, weight: .regular))
                    .foregroundStyle(.inkSecondary)
                    .padding(.bottom, 20)
            }
            Text("DRAG THE DIAL")
                .font(Typography.eyebrow(size: 10.5))
                .tracking(3.5)
                .foregroundStyle(.inkTertiary)
        }
    }

    /// Horizontally scrollable preset chips. The currently-selected value gets
    /// the prominent style.
    private var presetRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(presets, id: \.self) { value in
                    PresetChip(value: value, isSelected: minutes == value) {
                        withAnimation(.snappy) { minutes = value }
                    }
                }
            }
            .padding(.horizontal, 24)
        }
    }

    /// Side-by-side eyebrow-titled pills for the current sound and bells.
    private var soundAndBellsRow: some View {
        HStack(spacing: 10) {
            LabeledPill(
                eyebrow: "SOUND",
                value: soundName,
                icon: { wavelengthIcon }
            )
            LabeledPill(
                eyebrow: "BELLS",
                value: bellsSummary,
                icon: { bellIcon }
            )
        }
    }

    // SF Symbols approximate the design's hand-drawn glyphs closely enough for
    // V1; we'll swap to custom SVG-derived shapes when polishing.
    private var wavelengthIcon: some View {
        Image(systemName: "waveform")
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(.inkTertiary)
    }

    private var bellIcon: some View {
        Image(systemName: "bell")
            .font(.system(size: 12, weight: .regular))
            .foregroundStyle(.inkTertiary)
    }
}

// MARK: - Top bar

private struct HomeTopBar: View {
    let streak: Int

    var body: some View {
        HStack {
            iconButton(systemName: "gearshape") { /* settings */ }
            Spacer()
            HStack(spacing: 8) {
                streakPill
                iconButton(systemName: "chart.bar") { /* stats */ }
            }
        }
    }

    private var streakPill: some View {
        HStack(spacing: 8) {
            Text("\(streak)")
                .font(Typography.body(size: 15, weight: .medium))
                .foregroundStyle(.ink)
            Image(systemName: "flame")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.warmAccent)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .glassSurface(radius: Radius.pill, tint: 0.55)
    }

    private func iconButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.ink)
                .frame(width: 44, height: 44)
                .glassSurface(radius: 22, tint: 0.55)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preset chip

private struct PresetChip: View {
    let value: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(value)")
                .font(Typography.body(size: 14, weight: .medium))
                .foregroundStyle(isSelected ? .ink : .inkSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .glassSurface(
                    radius: Radius.pill,
                    tint: isSelected ? 0.92 : 0.50
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Labeled pill (Sound / Bells)

private struct LabeledPill<Icon: View>: View {
    let eyebrow: String
    let value: String
    @ViewBuilder var icon: () -> Icon

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                icon()
                Text(eyebrow)
                    .font(Typography.eyebrow(size: 10.5))
                    .tracking(2.5)
                    .foregroundStyle(.inkTertiary)
            }
            Text(value)
                .font(Typography.body(size: 15, weight: .medium))
                .foregroundStyle(.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassSurface(radius: 20, tint: 0.55)
    }
}

#Preview {
    HomeView()
}
