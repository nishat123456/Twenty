import SwiftUI

struct LandingView: View {
    let onStart: () -> Void
    @State private var appeared = false

    var body: some View {
        ZStack {
            Theme.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .stroke(Theme.gold, lineWidth: 6)
                            .frame(width: 116, height: 116)
                        Text("20")
                            .font(Theme.serif(50))
                            .foregroundStyle(Theme.green)
                    }
                    .padding(.bottom, 6)

                    Text("Twenty")
                        .font(Theme.serif(46))
                        .foregroundStyle(Theme.green)

                    Text("Twenty questions before you buy.")
                        .font(.system(.title3, design: .serif))
                        .italic()
                        .foregroundStyle(Theme.ink.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 22) {
                    FeatureRow(icon: "magnifyingglass", title: "Pick a stock",
                               detail: "Enter any ticker symbol")
                    FeatureRow(icon: "checklist", title: "Answer 20 questions",
                               detail: "6 fill in automatically from live data")
                    FeatureRow(icon: "chart.bar.doc.horizontal", title: "Get your score",
                               detail: "A recommendation and a PDF report")
                }
                .padding(.horizontal, 36)

                Spacer()

                Button(action: onStart) {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundStyle(Theme.cream)
                        .background(Theme.green, in: Capsule())
                }
                .padding(.horizontal, 32)

                Text("Inspired by Warren Buffett's value investing")
                    .font(.footnote)
                    .foregroundStyle(Theme.ink.opacity(0.5))
                    .padding(.top, 14)
                    .padding(.bottom, 8)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                appeared = true
            }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Theme.green)
                .frame(width: 48, height: 48)
                .background(Theme.green.opacity(0.1), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(Theme.ink.opacity(0.6))
            }
        }
    }
}

#Preview {
    LandingView(onStart: {})
}
