import SwiftUI

struct AppTheme {
    let surfacePrimary: Color
    let surfaceTertiary: Color
    let textPrimary: Color
    let textSecondary: Color
    let border: Color

    static let light = AppTheme(
        surfacePrimary: Color(hex: 0xFFFFFF),
        surfaceTertiary: Color(hex: 0xF0F0F0),
        textPrimary: Color(hex: 0x181818),
        textSecondary: Color(hex: 0x5F5F5F),
        border: Color(hex: 0xDCDCDC)
    )

    static let dark = AppTheme(
        surfacePrimary: Color(hex: 0x000000),
        surfaceTertiary: Color(hex: 0x1A1A1A),
        textPrimary: Color(hex: 0xFFFFFF),
        textSecondary: Color(hex: 0x999999),
        border: Color(hex: 0x2A2A2A)
    )
}

extension Color {
    init(hex: UInt, opacity: Double = 1.0) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

struct ThemeKey: EnvironmentKey {
    static let defaultValue = AppTheme.light
}

extension EnvironmentValues {
    var theme: AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
