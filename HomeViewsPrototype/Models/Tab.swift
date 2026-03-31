import SwiftUI

enum Tab: Int, CaseIterable, Identifiable {
    case forYou = 0
    case following = 1
    case trending = 2

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .forYou: return "For you"
        case .following: return "Following"
        case .trending: return "Trending"
        }
    }

    var tintRGB: (r: Double, g: Double, b: Double)? {
        switch self {
        case .forYou: return (0, 74, 206)
        case .following: return nil
        case .trending: return (5, 150, 70)
        }
    }

    var tintColor: Color? {
        guard let rgb = tintRGB else { return nil }
        return Color(red: rgb.r / 255, green: rgb.g / 255, blue: rgb.b / 255)
    }
}
