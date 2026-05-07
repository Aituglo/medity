import SwiftData
import SwiftUI

/// Settings — accessed from the gear icon on `HomeView`. Five grouped sections:
/// Reminder, Defaults, Health & sync, Medity Plus, About.
///
/// All persisted state lives on the singleton `UserPreferences`. The
/// reminder section reactively re-syncs `ReminderScheduler` whenever any
/// field of the schedule changes.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(HealthStore.self) private var healthStore
    @Query private var prefsList: [UserPreferences]

    var body: some View {
        ZStack {
            Backdrop(.day)
            VStack(spacing: 0) {
                topBar
                if let prefs = prefsList.first {
                    SettingsContent(prefs: prefs)
                } else {
                    Spacer()
                }
            }
        }
        .onAppear {
            // Lazy first-launch creation. UserPreferences should already
            // exist after onboarding, but we don't take it on faith.
            if prefsList.isEmpty {
                modelContext.insert(UserPreferences())
                try? modelContext.save()
            }
        }
    }

    private var topBar: some View {
        HStack {
            Color.clear.frame(width: 44, height: 44)
            Spacer()
            Text("Settings")
                .font(Typography.body(size: 18))
                .foregroundStyle(.ink)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.ink)
                    .frame(width: 44, height: 44)
                    .glassSurface(radius: 22, interactive: true)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, Spacing.xl)
        .padding(.top, Spacing.l)
    }
}

// MARK: - Content

private struct SettingsContent: View {
    @Bindable var prefs: UserPreferences
    @Environment(HealthStore.self) private var healthStore
    private let scheduler = ReminderScheduler()

    @State private var presentingSheet: SheetTarget?

    enum SheetTarget: Identifiable {
        case time, days, duration
        var id: Self { self }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                reminderSection
                defaultsSection
                healthSection
                plusSection
                aboutSection
            }
            .padding(.top, 12)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
        .onChange(of: prefs.reminderEnabled) { _, _ in resyncReminder() }
        .onChange(of: prefs.reminderHour) { _, _ in resyncReminder() }
        .onChange(of: prefs.reminderMinute) { _, _ in resyncReminder() }
        .onChange(of: prefs.reminderDaysBitmask) { _, _ in resyncReminder() }
        .sheet(item: $presentingSheet) { target in
            sheet(for: target)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private func sheet(for target: SheetTarget) -> some View {
        switch target {
        case .time:     ReminderTimePicker(prefs: prefs)
        case .days:     ReminderDaysPicker(prefs: prefs)
        case .duration: DurationPicker(prefs: prefs)
        }
    }

    // MARK: Reminder

    private var reminderSection: some View {
        SettingsGroup(header: "Reminder") {
            SettingsRow(
                label: "Daily reminder",
                toggle: $prefs.reminderEnabled
            )
            SettingsRow(
                label: "At",
                detail: prefs.reminderTimeFormatted,
                chevron: true,
                isEnabled: prefs.reminderEnabled,
                onTap: { presentingSheet = .time }
            )
            SettingsRow(
                label: "Days",
                detail: prefs.reminderDaysSummary,
                chevron: true,
                isEnabled: prefs.reminderEnabled,
                isLast: true,
                onTap: { presentingSheet = .days }
            )
        }
    }

    // MARK: Defaults

    private var defaultsSection: some View {
        SettingsGroup(header: "Defaults") {
            SettingsRow(
                label: "Duration",
                detail: "\(prefs.defaultDurationMinutes) min",
                chevron: true,
                onTap: { presentingSheet = .duration }
            )
            SettingsRow(
                label: "Sound",
                detail: prefs.defaultSoundDisplayName,
                chevron: true,
                onTap: { /* SoundLibrary — TBD */ }
            )
            SettingsRow(
                label: "Bells",
                detail: "Start & End",
                chevron: true,
                isLast: true,
                onTap: { /* BellsPicker — TBD */ }
            )
        }
    }

    // MARK: Health & sync

    private var healthSection: some View {
        SettingsGroup(
            header: "Health & sync",
            footer: "Sessions are written to Apple Health as Mindful Minutes."
        ) {
            // The OS doesn't let an app revoke its own HealthKit
            // authorization — once granted the user manages it from the
            // system Health app. So this row only has one direction:
            // re-prompt when not yet granted; otherwise it's a status row.
            SettingsRow(
                label: "Apple Health",
                detail: healthStore.canWriteMindfulMinutes ? "Granted" : "Tap to allow",
                onTap: {
                    Task { await healthStore.requestAuthorization() }
                }
            )
            SettingsRow(
                label: "iCloud sync",
                detail: "Local only",
                isLast: true
            )
        }
    }

    // MARK: Plus

    private var plusSection: some View {
        SettingsGroup(header: "Medity Plus") {
            SettingsRow(
                label: "Restore purchases",
                accent: true,
                onTap: { /* StoreKit restore — TBD */ }
            )
            SettingsRow(
                label: "Unlock Medity Plus",
                detail: "€14.99",
                chevron: true,
                accent: true,
                isLast: true,
                onTap: { /* Paywall — TBD */ }
            )
        }
    }

    // MARK: About

    private var aboutSection: some View {
        SettingsGroup(header: "About") {
            SettingsRow(label: "Privacy", chevron: true, onTap: { /* TBD */ })
            SettingsRow(label: "Acknowledgements", chevron: true, onTap: { /* TBD */ })
            SettingsRow(label: "Version", detail: appVersion, isLast: true)
        }
    }

    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0"
        let year = Calendar.current.component(.year, from: Date())
        return "\(version) · \(year)"
    }

    // MARK: Reminder syncing

    private func resyncReminder() {
        Task {
            if prefs.reminderEnabled {
                await scheduler.schedule(
                    hour: prefs.reminderHour,
                    minute: prefs.reminderMinute,
                    daysBitmask: prefs.reminderDaysBitmask
                )
            } else {
                await scheduler.cancel()
            }
        }
    }
}

// MARK: - Reusable row + group

private struct SettingsGroup<Content: View>: View {
    let header: String?
    let footer: String?
    @ViewBuilder var content: () -> Content

    init(header: String? = nil, footer: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.header = header
        self.footer = footer
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let header {
                Text(header.uppercased())
                    .font(Typography.eyebrow())
                    .tracking(2.5)
                    .foregroundStyle(.inkTertiary)
                    .padding(.horizontal, 22)
                    .padding(.bottom, 8)
            }
            VStack(spacing: 0) { content() }
                .glassSurface(radius: 20)
                .padding(.horizontal, 14)
            if let footer {
                Text(footer)
                    .font(Typography.body(size: 12))
                    .foregroundStyle(.inkTertiary)
                    .lineSpacing(2)
                    .padding(.horizontal, 22)
                    .padding(.top, 10)
            }
        }
    }
}

private struct SettingsRow: View {
    let label: String
    var detail: String? = nil
    var toggle: Binding<Bool>? = nil
    var chevron: Bool = false
    var accent: Bool = false
    /// Disabled rows are still rendered; their tap is suppressed and
    /// foreground colors fade so they read as inactive (e.g. reminder
    /// time/days when the master toggle is off).
    var isEnabled: Bool = true
    var isLast: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        Group {
            if let onTap, isEnabled {
                Button(action: onTap) { rowBody }
                    .buttonStyle(.plain)
            } else {
                rowBody
            }
        }
        .opacity(isEnabled ? 1 : 0.4)
    }

    private var rowBody: some View {
        HStack(spacing: 0) {
            Text(label)
                .font(Typography.body(size: 16))
                .foregroundStyle(accent ? .accent : .ink)
            Spacer()
            if let detail {
                Text(detail)
                    .font(Typography.body(size: 15))
                    .foregroundStyle(.inkSecondary)
                    .padding(.trailing, chevron ? 6 : 0)
            }
            if let toggle {
                Toggle("", isOn: toggle)
                    .labelsHidden()
                    .tint(.accent)
            }
            if chevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.inkTertiary)
            }
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 18)
        .frame(minHeight: 50)
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle()
                    .fill(.hairline)
                    .frame(height: 0.5)
                    .padding(.leading, 18)
            }
        }
    }
}

// MARK: - Sub-pickers (sheets)

private struct ReminderTimePicker: View {
    @Bindable var prefs: UserPreferences
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Backdrop(.day)
            VStack(spacing: 24) {
                Text("Reminder time")
                    .font(Typography.display(size: 24, weight: .light))
                    .foregroundStyle(.ink)
                    .padding(.top, 28)

                DatePicker(
                    "Reminder time",
                    selection: timeBinding,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.horizontal, 28)

                Spacer()

                PrimaryButton("Done", icon: .arrow) { dismiss() }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 24)
            }
        }
    }

    private var timeBinding: Binding<Date> {
        Binding(
            get: {
                var c = DateComponents()
                c.hour = prefs.reminderHour
                c.minute = prefs.reminderMinute
                return Calendar.current.date(from: c) ?? Date()
            },
            set: { newValue in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                prefs.reminderHour = c.hour ?? 7
                prefs.reminderMinute = c.minute ?? 0
            }
        )
    }
}

private struct ReminderDaysPicker: View {
    @Bindable var prefs: UserPreferences
    @Environment(\.dismiss) private var dismiss

    private let names = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    var body: some View {
        ZStack {
            Backdrop(.day)
            VStack(spacing: 0) {
                Text("Reminder days")
                    .font(Typography.display(size: 24, weight: .light))
                    .foregroundStyle(.ink)
                    .padding(.top, 28)

                VStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { i in
                        dayRow(i, isLast: i == 6)
                    }
                }
                .glassSurface(radius: 20)
                .padding(.horizontal, 14)
                .padding(.top, 24)

                Spacer()

                PrimaryButton("Done", icon: .arrow) { dismiss() }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 24)
            }
        }
    }

    private func dayRow(_ index: Int, isLast: Bool) -> some View {
        HStack {
            Text(names[index])
                .font(Typography.body(size: 16))
                .foregroundStyle(.ink)
            Spacer()
            Toggle("", isOn: dayBinding(index))
                .labelsHidden()
                .tint(.accent)
        }
        .padding(.horizontal, 18)
        .frame(minHeight: 50)
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle()
                    .fill(.hairline)
                    .frame(height: 0.5)
                    .padding(.leading, 18)
            }
        }
    }

    private func dayBinding(_ index: Int) -> Binding<Bool> {
        Binding(
            get: { prefs.reminderDaysBitmask & (1 << index) != 0 },
            set: { newValue in
                if newValue {
                    prefs.reminderDaysBitmask |= (1 << index)
                } else {
                    prefs.reminderDaysBitmask &= ~(1 << index)
                }
            }
        )
    }
}

private struct DurationPicker: View {
    @Bindable var prefs: UserPreferences
    @Environment(\.dismiss) private var dismiss

    private let options = [3, 5, 10, 15, 20, 25, 30, 35, 40, 45, 60]

    var body: some View {
        ZStack {
            Backdrop(.day)
            VStack(spacing: 0) {
                Text("Default duration")
                    .font(Typography.display(size: 24, weight: .light))
                    .foregroundStyle(.ink)
                    .padding(.top, 28)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(options, id: \.self) { mins in
                            durationRow(mins, isLast: mins == options.last)
                        }
                    }
                    .glassSurface(radius: 20)
                    .padding(.horizontal, 14)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private func durationRow(_ mins: Int, isLast: Bool) -> some View {
        Button {
            prefs.defaultDurationMinutes = mins
            dismiss()
        } label: {
            HStack {
                Text("\(mins) min")
                    .font(Typography.body(size: 16))
                    .foregroundStyle(.ink)
                Spacer()
                if mins == prefs.defaultDurationMinutes {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.accent)
                }
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 18)
            .frame(minHeight: 50)
            .overlay(alignment: .bottom) {
                if !isLast {
                    Rectangle()
                        .fill(.hairline)
                        .frame(height: 0.5)
                        .padding(.leading, 18)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - UserPreferences display helpers

private extension UserPreferences {
    /// Localized "h:mm a" rendering of the reminder time.
    var reminderTimeFormatted: String {
        var c = DateComponents()
        c.hour = reminderHour
        c.minute = reminderMinute
        guard let date = Calendar.current.date(from: c) else { return "—" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Compact summary of the active days. Special-cases the common
    /// Mon–Fri / Sat–Sun / Every day shortcuts; otherwise lists short
    /// names separated by commas.
    var reminderDaysSummary: String {
        let bits = reminderDaysBitmask
        switch bits {
        case 0b1111111: return "Every day"
        case 0b0111110: return "Mon–Fri"
        case 0b1000001: return "Sat–Sun"
        case 0:         return "None"
        default:
            let short = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            var picked: [String] = []
            for i in 0..<7 where bits & (1 << i) != 0 {
                picked.append(short[i])
            }
            return picked.joined(separator: ", ")
        }
    }

    /// Display name for the default sound; `nil` and `"silence"` map to
    /// "Silence", otherwise we humanize "rain.light" → "Rain · Light".
    var defaultSoundDisplayName: String {
        guard let id = defaultSoundIdentifier, id != "silence" else { return "Silence" }
        return id
            .split(separator: ".")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " · ")
    }
}

#Preview {
    SettingsView()
        .environment(HealthStore())
        .modelContainer(for: [Session.self, UserPreferences.self], inMemory: true)
}
