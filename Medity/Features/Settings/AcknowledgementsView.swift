import SwiftUI

/// Credits screen — pushes (sheet) from Settings → Acknowledgements.
///
/// Lists every third-party asset that ships in the bundle along with its
/// author and licence. Required for compliance with the CC-BY / CC-BY-SA
/// works in `Resources/Sounds/`.
struct AcknowledgementsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Backdrop(.day)
            VStack(spacing: 0) {
                topBar
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        intro
                        creditsSection(title: "Sounds — nature & ambient", entries: ambientCredits)
                        creditsSection(title: "Sounds — music", entries: musicCredits)
                        creditsSection(title: "Bell", entries: bellCredits)
                        creditsSection(title: "Typography", entries: typographyCredits)
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.ink)
                    .frame(width: 44, height: 44)
                    .glassSurface(radius: 22, interactive: true)
            }
            .buttonStyle(.plain)
            Spacer()
            Text("Acknowledgements")
                .font(Typography.body(size: 18))
                .foregroundStyle(.ink)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.l)
    }

    private var intro: some View {
        Text("Medity ships with works generously made available under permissive licences. Each credit below links to the original source.")
            .font(Typography.body(size: 14))
            .foregroundStyle(.inkSecondary)
            .lineSpacing(2)
            .padding(.top, 12)
            .padding(.horizontal, 4)
    }

    private func creditsSection(title: String, entries: [Credit]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title.uppercased())
                .font(Typography.eyebrow())
                .tracking(2.5)
                .foregroundStyle(.inkTertiary)
                .padding(.bottom, 8)
                .padding(.leading, 6)

            VStack(spacing: 0) {
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, credit in
                    CreditRow(credit: credit, isLast: index == entries.count - 1)
                }
            }
            .glassSurface(radius: 20)
        }
    }
}

// MARK: - Data

private struct Credit: Identifiable, Hashable {
    let id: String
    let title: String
    let author: String
    let license: String
    let url: URL?
}

private let ambientCredits: [Credit] = [
    Credit(id: "rain-light", title: "Rain (light)", author: "cori",
           license: "Public Domain",
           url: URL(string: "https://commons.wikimedia.org/wiki/File:Rain_against_the_window.ogg")),
    Credit(id: "rain-heavy", title: "Rain (heavy)", author: "Beeld en Geluid",
           license: "CC BY-SA 3.0",
           url: URL(string: "https://commons.wikimedia.org/wiki/File:Regen_op_een_pannendak_-_SoundCloud_-_Beeld_en_Geluid.ogg")),
    Credit(id: "ocean-waves", title: "Ocean waves", author: "Dsw4",
           license: "Public Domain",
           url: URL(string: "https://commons.wikimedia.org/wiki/File:Waves.ogg")),
    Credit(id: "forest", title: "Forest ambience", author: "nille",
           license: "Public Domain",
           url: URL(string: "https://commons.wikimedia.org/wiki/File:20090610_0_ambience.ogg")),
    Credit(id: "river", title: "River — water on rocks", author: "Dsw4",
           license: "CC BY 3.0",
           url: URL(string: "https://commons.wikimedia.org/wiki/File:Water_on_Rocks.ogg")),
    Credit(id: "fire", title: "Campfire", author: "Glaneur de sons",
           license: "CC BY 3.0",
           url: URL(string: "https://commons.wikimedia.org/wiki/File:Campfire_sound_ambience.ogg")),
    Credit(id: "wind", title: "Wind", author: "Tvabutzku1234",
           license: "CC0",
           url: URL(string: "https://commons.wikimedia.org/wiki/File:Howling_wind.ogg")),
]

private let musicCredits: [Credit] = [
    Credit(id: "universe", title: "Universe", author: "HoliznaCC0",
           license: "CC0",
           url: URL(string: "https://freemusicarchive.org/music/holiznacc0/space-sleep-meditation/20-minute-meditation-1/")),
    Credit(id: "nature", title: "Nature", author: "HoliznaCC0",
           license: "CC0",
           url: URL(string: "https://freemusicarchive.org/music/holiznacc0/space-sleep-meditation/20-minute-meditation-7/")),
    Credit(id: "spatium", title: "Spatium", author: "HoliznaCC0",
           license: "CC0",
           url: URL(string: "https://freemusicarchive.org/music/holiznacc0/space-sleep-meditation/too-brief-a-time-to-be-anything/")),
    Credit(id: "classical", title: "Classical", author: "Alex Wit (via Pixabay)",
           license: "Pixabay License",
           url: URL(string: "https://www.youtube.com/watch?v=xiIXNnJXpwo")),
    Credit(id: "canyon", title: "Canyon", author: "Dandelion Meditation Music",
           license: "CC BY 4.0",
           url: URL(string: "https://www.youtube.com/watch?v=yd5b2L0gGqw")),
    Credit(id: "fountain", title: "Fountain", author: "Dandelion Meditation Music",
           license: "CC BY 4.0",
           url: URL(string: "https://www.youtube.com/watch?v=t0Om9Slw4as")),
]

private let bellCredits: [Credit] = [
    Credit(id: "bell", title: "Meditation Gong", author: "Marble Toast",
           license: "CC0",
           url: URL(string: "https://commons.wikimedia.org/wiki/File:Meditation_Gong.ogg")),
]

private let typographyCredits: [Credit] = [
    Credit(id: "geist", title: "Geist", author: "Vercel",
           license: "SIL Open Font License 1.1",
           url: URL(string: "https://github.com/vercel/geist-font")),
]

// MARK: - Row

private struct CreditRow: View {
    let credit: Credit
    let isLast: Bool

    var body: some View {
        Group {
            if let url = credit.url {
                Link(destination: url) { rowBody }
                    .buttonStyle(.plain)
            } else {
                rowBody
            }
        }
    }

    private var rowBody: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 2) {
                Text(credit.title)
                    .font(Typography.body(size: 16))
                    .foregroundStyle(.ink)
                Text("\(credit.author) · \(credit.license)")
                    .font(Typography.body(size: 12.5))
                    .foregroundStyle(.inkSecondary)
            }
            Spacer()
            if credit.url != nil {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.inkTertiary)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle().fill(.hairline).frame(height: 0.5).padding(.leading, 18)
            }
        }
    }
}

#Preview {
    AcknowledgementsView()
}
