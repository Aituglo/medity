import XCTest

/// Drives the app through every shippable surface and captures a screenshot
/// of each. The captures are exported as `XCTAttachment`s on the test
/// result, then peeled out of the .xcresult bundle by `Tools/extract-screenshots.sh`.
///
/// Run from the command line:
///
///     xcodebuild test -project Medity.xcodeproj -scheme Medity \
///         -only-testing:MedityUITests/AppStoreScreenshots \
///         -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' \
///         -resultBundlePath /tmp/medity-shots.xcresult
///
/// The launch arguments wipe the previous app state, skip onboarding, and
/// seed a believable session history so the heatmap, streak and metrics
/// look populated.
final class AppStoreScreenshots: XCTestCase {
    override class var runsForEachTargetApplicationUIConfiguration: Bool { false }

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    func testCaptureAllScreens() throws {
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(en-US)",
            "-AppleLocale", "en_US",
            "-seedMockSessions", "YES",
            "-hasCompletedOnboarding", "YES",
        ]
        app.launch()

        // Give SwiftData a beat to seed + the home its first layout pass.
        sleep(2)

        // 1) Home — the signature screen.
        snapshot("01-home", from: app)

        // 2) Sound library — tap the SOUND pill (eyebrow text is unique).
        let soundPill = app.staticTexts["SOUND"]
        if soundPill.waitForExistence(timeout: 2) {
            soundPill.tap()
            sleep(1)
            snapshot("02-sound-library", from: app)
            // Dismiss
            app.buttons["Done"].firstMatch.tap()
            sleep(1)
        }

        // 3) Bells picker — same pattern.
        let bellsPill = app.staticTexts["BELLS"]
        if bellsPill.waitForExistence(timeout: 2) {
            bellsPill.tap()
            sleep(1)
            snapshot("03-bells", from: app)
            app.buttons["Done"].firstMatch.tap()
            sleep(1)
        }

        // 4) Stats — top-right chart icon.
        let statsButton = app.buttons.matching(identifier: "chart.bar").firstMatch
        if statsButton.waitForExistence(timeout: 2) {
            statsButton.tap()
            sleep(1)
            snapshot("04-stats", from: app)

            // 5) Achievements / Markers — top-right rosette.
            let markersButton = app.buttons.matching(identifier: "rosette").firstMatch
            if markersButton.waitForExistence(timeout: 2) {
                markersButton.tap()
                sleep(1)
                snapshot("05-achievements", from: app)
                // Pop back to stats then home.
                app.buttons.matching(identifier: "chevron.left").firstMatch.tap()
                sleep(1)
            }
            // Pop stats back to home.
            app.buttons.matching(identifier: "chevron.left").firstMatch.tap()
            sleep(1)
        }

        // 6) Settings — top-left gear.
        let settingsButton = app.buttons.matching(identifier: "gearshape").firstMatch
        if settingsButton.waitForExistence(timeout: 2) {
            settingsButton.tap()
            sleep(1)
            snapshot("06-settings", from: app)
            app.buttons.matching(identifier: "xmark").firstMatch.tap()
            sleep(1)
        }
    }

    /// Take a screenshot of the whole window (not just the app's frame),
    /// name it for export, and keep it on the test result bundle.
    private func snapshot(_ name: String, from app: XCUIApplication) {
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
