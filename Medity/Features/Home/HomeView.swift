import SwiftData
import SwiftUI
import WidgetKit

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
    @State private var isPresentingSession = false
    @State private var isPresentingStats = false
    @State private var isPresentingSettings = false
    @State private var isPresentingSoundLibrary = false
    @State private var isPresentingBellsPicker = false
    /// Set on first appear so we don't reset the user's current dial value
    /// every time we come back from another screen.
    @State private var didSeedDefaultDuration = false

    /// All recorded sessions, newest first. Used to compute the live streak.
    @Query(sort: \Session.endedAt, order: .reverse) private var sessions: [Session]

    /// Singleton preferences. List-typed because @Query is a list, but the
    /// app guarantees only one row exists.
    @Query private var prefsList: [UserPreferences]

    private var streak: Int {
        Session.currentStreak(from: sessions)
    }

    var body: some View {
        ZStack {
            Backdrop(.dawn)

            VStack(spacing: 0) {
                HomeTopBar(
                    streak: streak,
                    onSettingsTap: { isPresentingSettings = true },
                    onStatsTap: { isPresentingStats = true }
                )
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.l)

                Spacer(minLength: 0)

                ZStack {
                    AuraView(size: 440)
                    TimerRing(minutes: $minutes)
                    timerLabel
                }
                // Cap the ZStack to the ring's intrinsic size. Without this
                // the AuraView (440 pt) would dictate the parent VStack's
                // width and push every sibling — top bar, chips, CTA — past
                // the screen edges on a 393 pt iPhone.
                .frame(width: 350, height: 350)

                presetRow
                    .padding(.top, Spacing.xl)

                soundAndBellsRow
                    .padding(.top, Spacing.l)
                    .padding(.horizontal, 28)

                Spacer(minLength: 0)

                PrimaryButton("\(minutes) min session", icon: .play) {
                    isPresentingSession = true
                }
                .padding(.horizontal, 28)
                .padding(.bottom, Spacing.xxl)
            }
        }
        .fullScreenCover(isPresented: $isPresentingSession) {
            SessionView(
                minutes: minutes,
                soundId: prefsList.first?.defaultSoundIdentifier,
                bellId: prefsList.first?.defaultBellIdentifier,
                intervalBellMinutes: prefsList.first?.defaultIntervalBellsMinutes
            )
        }
        .fullScreenCover(isPresented: $isPresentingStats) {
            StatsView()
        }
        .fullScreenCover(isPresented: $isPresentingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $isPresentingSoundLibrary) {
            if let prefs = prefsList.first {
                SoundLibraryView(prefs: prefs)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $isPresentingBellsPicker) {
            if let prefs = prefsList.first {
                BellsPickerView(prefs: prefs)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            // Seed the dial from the persisted default exactly once, on
            // first appear after launch. We don't want to reset the user's
            // current selection every time they pop back from Stats /
            // Settings / Session.
            if !didSeedDefaultDuration, let prefs = prefsList.first {
                minutes = prefs.defaultDurationMinutes
                didSeedDefaultDuration = true
            }
            // Refresh the widget on every home appearance so the streak
            // pill on the home screen and the widgets on the lock screen
            // stay in sync — covers the case where a session ended via
            // a system kill or the app was relaunched after a long pause.
            refreshWidgetStore()
        }
    }

    /// Push the latest aggregates to the App Group `UserDefaults` and ask
    /// the system to reload widgets. Mirrors the version inside
    /// `SessionView` — they refresh from the same query.
    private func refreshWidgetStore() {
        let weekSessions = Session.thisWeek(sessions)
        let last = sessions.max(by: { $0.endedAt < $1.endedAt })
        SharedStore.write(
            streak: Session.currentStreak(from: sessions),
            totalMinutes: Session.totalSeconds(in: sessions) / 60,
            weekMinutes: Session.totalSeconds(in: weekSessions) / 60,
            sessionsThisWeek: weekSessions.count,
            lastSessionDurationMinutes: last.map { $0.actualDurationSeconds / 60 },
            lastSessionEndedAt: last?.endedAt
        )
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Pieces

    /// The big duration readout at the center of the timer ring.
    private var timerLabel: some View {
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
    }

    /// Horizontally scrollable preset chips. The currently-selected value gets
    /// the prominent style.
    ///
    /// `scrollClipDisabled` is required: without it, the chips' glass shadows
    /// and Liquid Glass extents get clipped to the ScrollView's bounds, which
    /// rendered as a faint gray "rail" behind the row in iOS 26.
    private var presetRow: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(presets, id: \.self) { value in
                    PresetChip(value: value, isSelected: minutes == value) {
                        withAnimation(.snappy) { minutes = value }
                    }
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 8)
        }
        .scrollIndicators(.hidden)
        .scrollClipDisabled()
    }

    /// Side-by-side eyebrow-titled pills for the current sound and bells.
    private var soundAndBellsRow: some View {
        HStack(spacing: 10) {
            Button { isPresentingSoundLibrary = true } label: {
                LabeledPill(
                    eyebrow: "SOUND",
                    value: prefsList.first?.defaultSoundDisplayName ?? "Silence",
                    icon: { wavelengthIcon }
                )
            }
            .buttonStyle(.plain)
            Button { isPresentingBellsPicker = true } label: {
                LabeledPill(
                    eyebrow: "BELLS",
                    value: prefsList.first?.bellsSummary ?? "Start & End",
                    icon: { bellIcon }
                )
            }
            .buttonStyle(.plain)
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
    let onSettingsTap: () -> Void
    let onStatsTap: () -> Void

    var body: some View {
        HStack {
            iconButton(systemName: "gearshape", action: onSettingsTap)
            Spacer()
            HStack(spacing: 8) {
                if streak > 0 {
                    streakPill
                }
                iconButton(systemName: "chart.bar", action: onStatsTap)
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
        .glassSurface(radius: Radius.pill)
    }

    private func iconButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.ink)
                .frame(width: 44, height: 44)
                .glassSurface(radius: 22, interactive: true)
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
                    tint: isSelected ? 0.45 : 0,
                    interactive: true
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
        .glassSurface(radius: 20)
    }
}

#Preview {
    HomeView()
        .environment(HealthStore())
        .modelContainer(for: [Session.self, UserPreferences.self], inMemory: true)
}
