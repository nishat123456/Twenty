import SwiftUI

enum Theme {
    static let green = Color(hex: 0x1F4D3A)
    static let cream = Color(hex: 0xF6F1E7)
    static let card = Color(hex: 0xFFFCF6)
    static let gold = Color(hex: 0xB8893B)
    static let ink = Color(hex: 0x1C1C1C)

    static let scoreGreen = Color(hex: 0x2E7D4F)
    static let scoreAmber = Color(hex: 0xC98A1B)
    static let scoreRed = Color(hex: 0xB23A3A)

    static func scoreColor(_ score: Int) -> Color {
        if score >= 16 { return scoreGreen }
        if score >= 12 { return scoreAmber }
        return scoreRed
    }

    static func serif(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
}
