import SwiftUI

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .foregroundStyle(.tint)
    }
}

enum Recommendation {
    case strongBuy, moderateBuy, notRecommended

    init(score: Int) {
        if score >= 16 {
            self = .strongBuy
        } else if score >= 12 {
            self = .moderateBuy
        } else {
            self = .notRecommended
        }
    }

    var title: String {
        switch self {
        case .strongBuy: "Strong Buy"
        case .moderateBuy: "Moderate Buy"
        case .notRecommended: "Not Recommended"
        }
    }

    var color: Color {
        switch self {
        case .strongBuy: Theme.positive
        case .moderateBuy: Theme.neutral
        case .notRecommended: Theme.negative
        }
    }
}
