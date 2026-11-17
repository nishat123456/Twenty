import SwiftUI
import SwiftData

@main
struct TwentyApp: App {
    @State private var showingLanding = true

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            StockEvaluation.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showingLanding {
                    LandingView {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showingLanding = false
                        }
                    }
                    .transition(.opacity)
                } else {
                    ContentView()
                        .transition(.opacity)
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
