import SwiftUI
import WidgetKit

/// Widget bundle for Medity — registers every widget surface the system
/// can offer the user, plus the Live Activity that shows during a session.
@main
struct MedityWidgetsBundle: WidgetBundle {
    var body: some Widget {
        StreakWidget()
        SessionLiveActivity()
    }
}
