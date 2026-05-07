import SwiftUI

/// Bottom sheet listing every sound by section, with a check on the
/// currently-selected one. Tapping a row updates `prefs.defaultSoundIdentifier`
/// and dismisses; tapping a Plus-locked row is a no-op for now (the paywall
/// will plug in here later).
///
/// Designed to be presented with `.presentationDetents([.large])`.
struct SoundLibraryView: View {
    @Bindable var prefs: UserPreferences
    @Environment(\.dismiss) private var dismiss
    @Environment(AudioEngine.self) private var audio
    @State private var isPresentingPaywall = false

    var body: some View {
        ZStack {
            Backdrop(.dawn)
            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        ForEach(SoundCatalog.Category.allCases, id: \.self) { category in
                            section(for: category)
                        }
                        if !prefs.hasUnlockedPlus {
                            PlusUpsellCard { isPresentingPaywall = true }
                                .padding(.horizontal, 14)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
        .onAppear {
            // Preview whatever is currently selected, so opening the sheet
            // immediately tells the user "this is what your sessions sound like".
            audio.playBackground(soundId: prefs.defaultSoundIdentifier)
        }
        .onDisappear {
            audio.stopAll()
        }
        .sheet(isPresented: $isPresentingPaywall) {
            PaywallView(prefs: prefs)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Sound")
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
        .padding(.bottom, 10)
    }

    private func section(for category: SoundCatalog.Category) -> some View {
        let sounds = SoundCatalog.sounds(in: category)
        return VStack(alignment: .leading, spacing: 0) {
            Text(category.rawValue.uppercased())
                .font(Typography.eyebrow())
                .tracking(3)
                .foregroundStyle(.inkTertiary)
                .padding(.horizontal, 22)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(Array(sounds.enumerated()), id: \.element.id) { index, sound in
                    SoundRow(
                        sound: sound,
                        isSelected: prefs.defaultSoundIdentifier == sound.id,
                        isLast: index == sounds.count - 1,
                        isUnlocked: !sound.isPremium || prefs.hasUnlockedPlus,
                        onTap: { select(sound) }
                    )
                }
            }
            .glassSurface(radius: 22)
            .padding(.horizontal, 14)
        }
    }

    private func select(_ sound: SoundCatalog.Sound) {
        // Locked sounds are visually dimmed — guard against tap anyway.
        guard !sound.isPremium || prefs.hasUnlockedPlus else { return }
        prefs.defaultSoundIdentifier = sound.id
        // Preview live so the user can compare options without committing.
        audio.playBackground(soundId: sound.id)
    }
}

// MARK: - Row

private struct SoundRow: View {
    let sound: SoundCatalog.Sound
    let isSelected: Bool
    let isLast: Bool
    let isUnlocked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                MiniWaveform(active: isSelected)
                    .frame(width: 32, height: 14)
                Text(sound.displayName)
                    .font(Typography.body(size: 17))
                    .foregroundStyle(.ink)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.accent)
                }
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.inkTertiary)
                }
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .overlay(alignment: .bottom) {
                if !isLast {
                    Rectangle().fill(.hairline).frame(height: 0.5)
                        .padding(.leading, 66)
                }
            }
        }
        .buttonStyle(.plain)
        .opacity(isUnlocked ? 1 : 0.55)
    }
}

/// Small bar-graph-style waveform — colored when the row is selected,
/// neutral otherwise.
private struct MiniWaveform: View {
    let active: Bool

    /// Pre-baked heights — picked once for visual consistency. Computed
    /// from `2 + |sin(i·0.9)|·10 + (i%3)` (the prototype's formula).
    private static let heights: [CGFloat] = [
        2, 10.78, 13.69, 6.21, 7.40, 13.79, 5.14, 6.24, 13.73, 7.44,
        2.21, 11.78, 11.69, 4.20
    ]

    var body: some View {
        HStack(alignment: .center, spacing: 0.9) {
            ForEach(Self.heights.indices, id: \.self) { i in
                RoundedRectangle(cornerRadius: 0.7)
                    .fill(active ? Color.accent : Color.inkTertiary)
                    .frame(width: 1.4, height: Self.heights[i])
            }
        }
    }
}

// MARK: - Plus upsell card

private struct PlusUpsellCard: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(LinearGradient(
                            colors: [Color(hex: 0xDDE6F3), Color(hex: 0xB6C8DE)],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .frame(width: 44, height: 44)
                    Circle()
                        .stroke(Color.ink, lineWidth: 1)
                        .frame(width: 18, height: 18)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Medity Plus")
                        .font(Typography.display(size: 18, weight: .regular))
                        .foregroundStyle(.ink)
                    Text("Unlock all sounds, bells, themes.")
                        .font(Typography.body(size: 13))
                        .foregroundStyle(.inkSecondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.inkTertiary)
            }
            .padding(18)
            .glassSurface(radius: 22, tint: 0.40, interactive: true)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var prefs = UserPreferences()
    return SoundLibraryView(prefs: prefs)
        .environment(AudioEngine())
}
