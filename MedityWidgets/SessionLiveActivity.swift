import ActivityKit
import SwiftUI
import WidgetKit

/// Live Activity for an in-progress meditation session.
///
/// Three Dynamic Island variants (compact, minimal, expanded) plus a Lock
/// Screen presentation that shows the countdown ring, current sound name
/// and a tappable pause/resume button (when running on iOS 17+).
struct SessionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SessionActivityAttributes.self) { context in
            // Lock Screen / Notification banner.
            LockScreenSession(context: context)
                .activityBackgroundTint(Color(hex: 0x0F1B2D, opacity: 0.6))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    LeadingExpanded(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    TrailingExpanded(context: context)
                }
                DynamicIslandExpandedRegion(.center) {
                    CenterExpanded(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    EmptyView()
                }
            } compactLeading: {
                Image(systemName: "circle.dotted")
                    .foregroundStyle(Color(hex: 0x9CC2FF))
            } compactTrailing: {
                Text(context.state.formattedTime)
                    .monospacedDigit()
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(.white)
            } minimal: {
                MinimalRing(context: context)
            }
            .keylineTint(Color(hex: 0x9CC2FF))
        }
    }
}

// MARK: - Lock Screen

private struct LockScreenSession: View {
    let context: ActivityViewContext<SessionActivityAttributes>

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ProgressRing(
                fraction: 1 - Double(context.state.remainingSeconds) / Double(max(1, context.attributes.totalSeconds))
            )
            .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 2) {
                Text("MEDITY")
                    .font(.system(size: 10, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.6))
                Text(context.state.formattedTime)
                    .font(.system(size: 30, weight: .light, design: .default))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                Text(context.attributes.soundDisplayName.uppercased())
                    .font(.system(size: 10, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.55))
            }
            Spacer()
            if context.state.isPaused {
                Image(systemName: "pause.fill")
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
    }
}

// MARK: - Dynamic Island regions

private struct LeadingExpanded: View {
    let context: ActivityViewContext<SessionActivityAttributes>
    var body: some View {
        HStack(spacing: 10) {
            ProgressRing(
                fraction: 1 - Double(context.state.remainingSeconds) / Double(max(1, context.attributes.totalSeconds))
            )
            .frame(width: 32, height: 32)
        }
    }
}

private struct CenterExpanded: View {
    let context: ActivityViewContext<SessionActivityAttributes>
    var body: some View {
        VStack(spacing: 2) {
            Text("MEDITY")
                .font(.system(size: 9, weight: .medium))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.55))
            Text(context.state.formattedTime)
                .font(.system(size: 22, weight: .light))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
    }
}

private struct TrailingExpanded: View {
    let context: ActivityViewContext<SessionActivityAttributes>
    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(context.attributes.soundDisplayName)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(.white)
                .lineLimit(1)
            if context.state.isPaused {
                Text("PAUSED")
                    .font(.system(size: 9, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(Color(hex: 0xC68B5C))
            } else {
                Text("RUNNING")
                    .font(.system(size: 9, weight: .medium))
                    .tracking(2)
                    .foregroundStyle(Color(hex: 0x9CC2FF))
            }
        }
    }
}

// MARK: - Minimal ring (Dynamic Island shared mode)

private struct MinimalRing: View {
    let context: ActivityViewContext<SessionActivityAttributes>
    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.2), lineWidth: 2.5)
            Circle()
                .trim(from: 0, to: 1 - Double(context.state.remainingSeconds) / Double(max(1, context.attributes.totalSeconds)))
                .stroke(Color(hex: 0x9CC2FF), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - Progress ring

private struct ProgressRing: View {
    let fraction: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.18), lineWidth: 2.5)
            Circle()
                .trim(from: 0, to: max(0, min(1, fraction)))
                .stroke(Color(hex: 0x9CC2FF), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
