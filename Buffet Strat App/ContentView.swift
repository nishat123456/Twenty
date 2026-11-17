import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StockEvaluation.evaluationDate, order: .reverse) private var evaluations: [StockEvaluation]
    @State private var showingAddChecklist = false
    @State private var showingSettings = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(evaluations) { evaluation in
                    NavigationLink(destination: EvaluationResultView(evaluation: evaluation)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(evaluation.tickerSymbol)
                                    .font(.headline)
                                Text(evaluation.evaluationDate, format: Date.FormatStyle(date: .numeric, time: .standard))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("\(evaluation.score)/20")
                                .bold()
                                .foregroundColor(scoreColor(evaluation.score))
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Evaluations")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Label("Settings", systemImage: "gear")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddChecklist = true
                    }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddChecklist) {
                ChecklistView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .overlay {
                if evaluations.isEmpty {
                    ContentUnavailableView("No Evaluations", systemImage: "chart.line.uptrend.xyaxis", description: Text("Tap + to evaluate a new stock."))
                }
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(evaluations[index])
            }
        }
    }
    
    private func scoreColor(_ score: Int) -> Color {
        if score >= 16 { return .green }
        if score >= 12 { return .orange }
        return .red
    }
}

#Preview {
    ContentView()
}
