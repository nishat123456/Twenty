import SwiftUI

enum Theme {
    static let accent = Color(hex: 0x1F3A5F)
    static let background = Color(hex: 0xEBF0F6)
    static let positive = Color(hex: 0x2E7D4F)
    static let neutral = Color(hex: 0xB7791F)
    static let negative = Color(hex: 0xB42318)
}

extension View {
    func screenBackground() -> some View {
        scrollContentBackground(.hidden)
            .background(Theme.background)
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
}
