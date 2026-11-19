import SwiftUI

struct LandingView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(.tint, lineWidth: 4)
                Text("20")
                    .font(.system(size: 30, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(.tint)
            }
            .frame(width: 76, height: 76)
            .padding(.bottom, 12)
            .accessibilityHidden(true)

            Text("Twenty")
                .font(.system(size: 64, weight: .heavy))
                .tracking(-1.5)
                .foregroundStyle(.tint)
                .padding(.top, 4)

            Text("Twenty questions before you buy.")
                .font(.title3)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 20) {
                StepRow(number: 1, title: "Pick a stock",
                        detail: "Enter a ticker symbol.")
                StepRow(number: 2, title: "Answer the checklist",
                        detail: "Six financial questions fill in from market data.")
                StepRow(number: 3, title: "Review the score",
                        detail: "Get a recommendation and a PDF report.")
            }
            .padding(.top, 48)

            Spacer()
            Spacer()

            Button(action: onStart) {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Text("Based on Warren Buffett's value investing principles.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
    }
}

private struct StepRow: View {
    let number: Int
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 14) {
            Text("\(number)")
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    LandingView(onStart: {})
}
