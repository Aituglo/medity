import Foundation

extension UserPreferences {
    /// "h:mm a" rendering of the reminder time, locale-aware.
    var reminderTimeFormatted: String {
        var c = DateComponents()
        c.hour = reminderHour
        c.minute = reminderMinute
        guard let date = Calendar.current.date(from: c) else { return "—" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    /// Compact summary of the active reminder days. Special-cases the
    /// common "Every day" / "Mon–Fri" / "Sat–Sun" shortcuts; otherwise
    /// lists short names separated by commas.
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

    /// Display name for the current default sound. Resolved through
    /// `SoundCatalog` so we don't repeat the mapping anywhere.
    var defaultSoundDisplayName: String {
        guard let id = defaultSoundIdentifier,
              let sound = SoundCatalog.sound(for: id)
        else { return "Silence" }
        return sound.displayName
    }

    /// Display name for the current default bell.
    var defaultBellDisplayName: String {
        BellCatalog.bell(for: defaultBellIdentifier)?.displayName ?? "Bell"
    }

    /// Compact one-line summary of the bell setup for the home pill: e.g.
    /// "Start & End" when interval bells are off, "Every 10 min" otherwise.
    var bellsSummary: String {
        if let minutes = defaultIntervalBellsMinutes, minutes > 0 {
            return "Every \(minutes) min"
        }
        return "Start & End"
    }
}
