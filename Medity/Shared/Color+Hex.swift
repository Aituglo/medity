import SwiftUI

extension Color {
    /// `Color(hex: 0x4A6FA5)` reads more directly than three CGFloat
    /// divisions. Defined in `Shared/` so both the main app and the widget
    /// extension can call it without duplicating the declaration.
    init(hex: UInt32, opacity: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8)  & 0xFF) / 255.0
        let b = Double( hex        & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
    }
}
