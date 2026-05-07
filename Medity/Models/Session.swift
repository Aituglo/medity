import Foundation
import SwiftData

/// A completed (or partially completed) meditation session.
///
/// Every persistent property has an inline default so the schema is
/// CloudKit-compatible — the migration from local-only to CloudKit-synced
/// just requires flipping `ModelConfiguration.cloudKitDatabase` without a
/// model rewrite. SwiftData's CloudKit integration rejects schemas where
/// any non-optional property lacks a default.
@Model
final class Session {
    /// Stable identifier — mirrored across CloudKit replicas.
    var id: UUID = UUID()

    /// Wall-clock start of the session.
    var startedAt: Date = Date()

    /// Wall-clock end (either timer expiry or user-tap "End").
    var endedAt: Date = Date()

    /// Duration the user picked when starting, in seconds.
    var plannedDurationSeconds: Int = 0

    /// What the user actually meditated, in seconds (excludes pause time).
    var actualDurationSeconds: Int = 0

    /// Identifier of the background sound (e.g. "rain.light"). `nil` = silence.
    var soundIdentifier: String? = nil

    /// Identifier of the bell timbre used (e.g. "tibetan-bowl").
    var bellIdentifier: String = "tibetan-bowl"

    /// Interval bells, in minutes. `nil` = off.
    var intervalBellsMinutes: Int? = nil

    /// `true` when the session ran to its planned duration; `false` when
    /// the user ended it early.
    var completed: Bool = true

    init(
        startedAt: Date,
        endedAt: Date,
        plannedDurationSeconds: Int,
        actualDurationSeconds: Int,
        soundIdentifier: String? = nil,
        bellIdentifier: String = "tibetan-bowl",
        intervalBellsMinutes: Int? = nil,
        completed: Bool = true
    ) {
        self.id = UUID()
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.plannedDurationSeconds = plannedDurationSeconds
        self.actualDurationSeconds = actualDurationSeconds
        self.soundIdentifier = soundIdentifier
        self.bellIdentifier = bellIdentifier
        self.intervalBellsMinutes = intervalBellsMinutes
        self.completed = completed
    }
}
