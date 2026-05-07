import SwiftData
import SwiftUI
import UIKit
import WidgetKit

/// Full-screen meditation session — countdown, ambient particles, pause/end.
///
/// Three phases drive what we render:
///   - `.running` and `.paused` share the countdown layout (the pause icon
///     swaps to play; the "End" affordance stays available)
///   - `.completed` swaps in a quiet "Well done" wrap-up screen with a
///     dismiss CTA back to home.
///
/// While on screen we disable the system idle timer so the device doesn't
/// dim mid-session. We re-enable it on disappear.
struct SessionView: View {
    let minutes: Int
    let soundId: String?
    let bellId: String?
    let intervalBellMinutes: Int?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(HealthStore.self) private var healthStore
    @Environment(AudioEngine.self) private var audio
    @State private var vm: SessionViewModel
    /// Guard against double-persisting on rapid phase transitions.
    @State private var persistedThisSession = false
    @State private var liveActivity = LiveActivityController()

    init(minutes: Int, soundId: String?, bellId: String? = nil, intervalBellMinutes: Int? = nil) {
        self.minutes = minutes
        self.soundId = soundId
        self.bellId = bellId
        self.intervalBellMinutes = intervalBellMinutes
        _vm = State(initialValue: SessionViewModel(minutes: minutes, intervalBellMinutes: intervalBellMinutes))
    }

    var body: some View {
        Group {
            switch vm.phase {
            case .running, .paused:
                runningView
                    .transition(.opacity)
            case .completed:
                CompletedView(elapsedSeconds: vm.elapsedSeconds) { dismiss() }
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: vm.phase)
        .preferredColorScheme(.light)
        .onAppear {
            // Soft tap on begin — the audible/sensory equivalent of the bell
            // in a meditation room.
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            UIApplication.shared.isIdleTimerDisabled = true
            audio.playBackground(soundId: soundId)
            audio.playBell(id: bellId)
            vm.start()
            liveActivity.start(
                totalSeconds: vm.totalSeconds,
                soundName: SoundCatalog.sound(for: soundId ?? "")?.displayName ?? "Silence",
                bellName: BellCatalog.bell(for: bellId ?? "")?.displayName ?? "Bell",
                remainingSeconds: vm.remainingSeconds
            )
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            audio.stopAll()
            Task { await liveActivity.end() }
        }
        .onChange(of: vm.phase) { old, new in
            // Pause / resume audio in lockstep with the timer state.
            switch (old, new) {
            case (_, .paused):                 audio.pause()
            case (.paused, .running):          audio.resume()
            default: break
            }

            if new == .completed {
                // Closing bell + slow fade of the ambient — let the room
                // return to quiet before the "Well done." view appears.
                audio.playBell(id: bellId)
                Task { await audio.fadeOutBackground(over: 3.0) }

                Task {
                    async let haptic: Void = playCompletionHaptic()
                    async let persist: Void = persistSession()
                    _ = await (haptic, persist)
                    await liveActivity.end()
                }
            } else {
                Task {
                    await liveActivity.update(
                        remainingSeconds: vm.remainingSeconds,
                        isPaused: vm.phase == .paused
                    )
                }
            }
        }
        .onChange(of: vm.remainingSeconds) { _, new in
            // Push every-second updates so the Dynamic Island and Lock
            // Screen countdowns tick smoothly with the in-app timer.
            guard vm.phase == .running else { return }
            Task {
                await liveActivity.update(
                    remainingSeconds: new,
                    isPaused: false
                )
            }
        }
        .onChange(of: vm.intervalBellCount) { _, _ in
            audio.playBell(id: bellId)
        }
    }

    /// Persists the session to SwiftData and mirrors it to HealthKit.
    /// Sessions shorter than a minute are dropped — they're almost always
    /// accidental taps and would pollute streak / stats data.
    private func persistSession() async {
        guard !persistedThisSession else { return }
        persistedThisSession = true

        guard let startDate = vm.startDate else { return }
        let endDate = Date()
        let actual = vm.elapsedSeconds

        guard actual >= 60 else { return }

        let session = Session(
            startedAt: startDate,
            endedAt: endDate,
            plannedDurationSeconds: vm.totalSeconds,
            actualDurationSeconds: actual,
            soundIdentifier: nil,
            bellIdentifier: "tibetan-bowl",
            completed: actual >= vm.totalSeconds
        )
        modelContext.insert(session)
        try? modelContext.save()

        await healthStore.saveSession(start: startDate, end: endDate)
        refreshWidgetStore()
    }

    /// Pushes the latest aggregates to the App Group store and asks the
    /// system to reload widget timelines. Errors here are non-fatal —
    /// widgets just continue to show stale data until the next session.
    private func refreshWidgetStore() {
        let descriptor = FetchDescriptor<Session>()
        guard let sessions = try? modelContext.fetch(descriptor) else { return }
        let weekSessions = Session.thisWeek(sessions)
        let last = sessions.max(by: { $0.endedAt < $1.endedAt })
        let streak = Session.currentStreak(from: sessions)
        SharedStore.write(
            streak: streak,
            totalMinutes: Session.totalSeconds(in: sessions) / 60,
            weekMinutes: Session.totalSeconds(in: weekSessions) / 60,
            sessionsThisWeek: weekSessions.count,
            lastSessionDurationMinutes: last.map { $0.actualDurationSeconds / 60 },
            lastSessionEndedAt: last?.endedAt
        )
        // Round-trip read so we know the App Group container actually
        // accepted the write — if these don't match, the entitlement
        // didn't take effect (free dev accounts on simulator usually OK).
        let echoed = SharedStore.streak
        print("[Widget] refresh streak=\(streak) sessions=\(sessions.count) echoed=\(echoed)")
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Running

    private var runningView: some View {
        ZStack {
            Backdrop(.day)
            AuraView(size: 520, intensity: 0.9)
            ParticleMist()

            // End — top, low-contrast on purpose so it's hard to tap by mistake.
            VStack {
                Button { vm.end() } label: {
                    Text("END")
                        .font(Typography.eyebrow(size: 13))
                        .tracking(4)
                        .foregroundStyle(.inkTertiary)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                }
                .buttonStyle(.plain)
                .padding(.top, Spacing.l)
                Spacer()
            }

            // Countdown — center.
            VStack(spacing: 14) {
                Text(vm.formattedTime)
                    .font(Typography.display(size: 96, weight: .thin))
                    .tracking(-2)
                    .monospacedDigit()
                    .foregroundStyle(.ink)
                    .contentTransition(.numericText(countsDown: true))
                Text(currentSoundLabel.uppercased())
                    .font(Typography.eyebrow(size: 11))
                    .tracking(4)
                    .foregroundStyle(.inkTertiary)
            }

            // Pause / Resume — bottom, the only chrome on screen.
            VStack {
                Spacer()
                Button {
                    vm.togglePause()
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } label: {
                    Image(systemName: vm.phase == .paused ? "play.fill" : "pause.fill")
                        .font(.system(size: 22, weight: .regular))
                        .foregroundStyle(.ink)
                        .frame(width: 56, height: 56)
                        .glassSurface(radius: Radius.pill, interactive: true)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 88)
            }
        }
    }

    /// Display label shown under the countdown — derived from the
    /// session's `soundId`, falling back to "Silence" when nothing is
    /// playing.
    private var currentSoundLabel: String {
        guard let soundId,
              let sound = SoundCatalog.sound(for: soundId)
        else { return "Silence" }
        return sound.displayName
    }

    /// Three soft pulses, half a second apart — the design's "completion"
    /// haptic language.
    private func playCompletionHaptic() async {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        for _ in 0..<3 {
            generator.impactOccurred()
            try? await Task.sleep(for: .milliseconds(500))
        }
    }
}

// MARK: - Completed

private struct CompletedView: View {
    let elapsedSeconds: Int
    let onDone: () -> Void

    var body: some View {
        ZStack {
            Backdrop(.day)
            AuraView(size: 280)
                .offset(y: -180)

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                Text("Well done.")
                    .font(Typography.display(size: 52, weight: .light))
                    .tracking(-0.5)
                    .foregroundStyle(.ink)

                Text(subtitle)
                    .font(Typography.body(size: 17))
                    .italic()
                    .foregroundStyle(.inkSecondary)
                    .padding(.top, 14)

                Spacer(minLength: 0)

                PrimaryButton("Done", icon: .arrow, action: onDone)
                    .padding(.horizontal, 28)
                    .padding(.bottom, Spacing.xxl)
            }
        }
    }

    /// Placeholder subtitle. Will read from streak state once persistence
    /// lands; for now we show the actual elapsed time so the user gets a
    /// real number even on early-end.
    private var subtitle: String {
        let m = elapsedSeconds / 60
        let s = elapsedSeconds % 60
        if m == 0 {
            return "\(s) seconds of stillness"
        } else if s == 0 {
            return "\(m) minute\(m == 1 ? "" : "s") of stillness"
        } else {
            return "\(m) min \(s) sec of stillness"
        }
    }
}

// MARK: - Particles

/// 22 slow-drifting motes that rise up the screen — "soft mist" per the
/// design. Pre-computed positions + cyclical wrap; no per-frame allocations.
private struct ParticleMist: View {
    private struct Seed { let x: CGFloat; let yOffset: CGFloat; let r: CGFloat; let opacity: Double }

    private let seeds: [Seed]

    init() {
        // Same deterministic distribution as the prototype — gives the
        // pleasing-but-non-uniform spread without a runtime PRNG.
        var built: [Seed] = []
        built.reserveCapacity(22)
        for i in 0..<22 {
            let x: CGFloat = CGFloat((i * 53) % 360 + 16)
            let yOffset: CGFloat = CGFloat((i * 89) % 600)
            let r: CGFloat = 0.8 + CGFloat(i % 3) * 0.5
            let opacity: Double = 0.18 + Double(i % 4) * 0.05
            built.append(Seed(x: x, yOffset: yOffset, r: r, opacity: opacity))
        }
        seeds = built
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                draw(in: ctx, size: size, time: t)
            }
        }
        .opacity(0.55)
        .allowsHitTesting(false)
    }

    /// Extracted from the Canvas closure — the type-checker times out when
    /// it sees the full body inline.
    private func draw(in ctx: GraphicsContext, size: CGSize, time t: Double) {
        let driftSpeed: Double = 8 // pt/s upward
        let cycle = Double(size.height) + 120

        for seed in seeds {
            let raised = (t * driftSpeed + Double(seed.yOffset)).truncatingRemainder(dividingBy: cycle)
            let y = size.height + 60 - CGFloat(raised)
            let rect = CGRect(
                x: seed.x - seed.r,
                y: y - seed.r,
                width: seed.r * 2,
                height: seed.r * 2
            )
            ctx.fill(Path(ellipseIn: rect), with: .color(Color.accent.opacity(seed.opacity)))
        }
    }
}

#Preview("Running") {
    SessionView(minutes: 1, soundId: "rain.light", bellId: "tibetan-bowl")
        .environment(HealthStore())
        .environment(AudioEngine())
        .modelContainer(for: [Session.self, UserPreferences.self], inMemory: true)
}
