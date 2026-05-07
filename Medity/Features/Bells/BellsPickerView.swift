import SwiftUI

/// Bell timbre + interval bells picker, presented as a sheet from the
/// "Bells" pill on `HomeView` and the "Bells" row in `SettingsView`.
///
/// Two sections:
///   1. Bell sound — list of timbres (synthesized + bundled). Tapping a row
///      sets it as the default and previews the bell so the user can hear
///      the choice immediately.
///   2. Interval bells — toggle to enable, segmented control for the
///      period (5 / 10 / 15 min). Live preview not provided here; the next
///      session will demonstrate it.
struct BellsPickerView: View {
    @Bindable var prefs: UserPreferences
    @Environment(\.dismiss) private var dismiss
    @Environment(AudioEngine.self) private var audio

    var body: some View {
        ZStack {
            Backdrop(.dawn)
            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        bellSoundSection
                        intervalSection
                        footerCopy
                    }
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
        .onDisappear { audio.stopAll() }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Bells")
                .font(Typography.display(size: 30, weight: .regular))
                .foregroundStyle(.ink)
            Spacer()
            Button("Done") { dismiss() }
                .font(Typography.body(size: 15, weight: .medium))
                .foregroundStyle(.accent)
                .buttonStyle(.plain)
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - Bell sound

    private var bellSoundSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("BELL SOUND")
                .font(Typography.eyebrow())
                .tracking(3)
                .foregroundStyle(.inkTertiary)
                .padding(.horizontal, 22)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(Array(BellCatalog.all.enumerated()), id: \.element.id) { index, bell in
                    BellRow(
                        bell: bell,
                        isSelected: prefs.defaultBellIdentifier == bell.id,
                        isLast: index == BellCatalog.all.count - 1,
                        onTap: { selectBell(bell) }
                    )
                }
            }
            .glassSurface(radius: 22)
            .padding(.horizontal, 14)
        }
    }

    private func selectBell(_ bell: BellCatalog.Bell) {
        prefs.defaultBellIdentifier = bell.id
        // Preview the bell so the user hears the choice immediately.
        audio.playBell(id: bell.id)
    }

    // MARK: - Interval bells

    private var intervalSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("INTERVAL BELLS")
                .font(Typography.eyebrow())
                .tracking(3)
                .foregroundStyle(.inkTertiary)
                .padding(.horizontal, 22)
                .padding(.bottom, 8)

            VStack(spacing: 14) {
                HStack {
                    Text("Ring during session")
                        .font(Typography.body(size: 16))
                        .foregroundStyle(.ink)
                    Spacer()
                    Toggle("", isOn: intervalEnabledBinding)
                        .labelsHidden()
                        .tint(.accent)
                }

                if intervalEnabledBinding.wrappedValue {
                    Rectangle().fill(.hairline).frame(height: 0.5)

                    IntervalSegmented(
                        choices: [5, 10, 15],
                        selected: prefs.defaultIntervalBellsMinutes ?? 10,
                        onSelect: { prefs.defaultIntervalBellsMinutes = $0 }
                    )
                }
            }
            .padding(18)
            .glassSurface(radius: 22)
            .padding(.horizontal, 14)
        }
    }

    /// Toggle drives the *presence* of an interval; flipping on defaults
    /// to 10 min, flipping off clears.
    private var intervalEnabledBinding: Binding<Bool> {
        Binding(
            get: { (prefs.defaultIntervalBellsMinutes ?? 0) > 0 },
            set: { newValue in
                prefs.defaultIntervalBellsMinutes = newValue ? 10 : nil
            }
        )
    }

    // MARK: - Footer

    private var footerCopy: some View {
        Text(footerText)
            .font(Typography.body(size: 12.5))
            .foregroundStyle(.inkSecondary)
            .lineSpacing(2)
            .padding(.horizontal, 22)
            .padding(.top, 6)
    }

    private var footerText: String {
        if let minutes = prefs.defaultIntervalBellsMinutes, minutes > 0 {
            return "A soft bell will ring at the start, every \(minutes) minutes, and at the end. It plays beneath the sound at low volume."
        } else {
            return "A soft bell will ring at the start and at the end of every session. It plays beneath the sound at low volume."
        }
    }
}

// MARK: - Row

private struct BellRow: View {
    let bell: BellCatalog.Bell
    let isSelected: Bool
    let isLast: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(.accent.opacity(0.10))
                        .frame(width: 32, height: 32)
                    Image(systemName: "bell.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(.accent)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(bell.displayName)
                        .font(Typography.body(size: 17))
                        .foregroundStyle(.ink)
                    Text(bell.subtitle)
                        .font(Typography.body(size: 12.5))
                        .foregroundStyle(.inkSecondary)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.accent)
                }
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .overlay(alignment: .bottom) {
                if !isLast {
                    Rectangle().fill(.hairline).frame(height: 0.5).padding(.leading, 64)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Segmented control

private struct IntervalSegmented: View {
    let choices: [Int]
    let selected: Int
    let onSelect: (Int) -> Void

    var body: some View {
        HStack(spacing: 4) {
            ForEach(choices, id: \.self) { choice in
                Button {
                    onSelect(choice)
                } label: {
                    Text("\(choice) min")
                        .font(Typography.body(size: 13, weight: .medium))
                        .foregroundStyle(choice == selected ? .ink : .inkSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background {
                            if choice == selected {
                                RoundedRectangle(cornerRadius: 9999, style: .continuous)
                                    .fill(.white)
                                    .shadow(color: .ink.opacity(0.08), radius: 4, x: 0, y: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .glassSurface(radius: 9999, tint: 0.10)
    }
}

#Preview {
    @Previewable @State var prefs = UserPreferences()
    return BellsPickerView(prefs: prefs)
        .environment(AudioEngine())
}
