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
                        EvaluationRow(evaluation: evaluation)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .screenBackground()
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
                    ContentUnavailableView {
                        Label("No Evaluations", systemImage: "list.bullet.rectangle")
                    } description: {
                        Text("Evaluate a stock against the 20-point checklist.")
                    } actions: {
                        Button("New Evaluation") {
                            showingAddChecklist = true
                        }
                    }
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
}

struct EvaluationRow: View {
    let evaluation: StockEvaluation

    var body: some View {
        let recommendation = Recommendation(score: evaluation.score)
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(evaluation.tickerSymbol)
                    .font(.headline)
                Text(evaluation.evaluationDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text("\(evaluation.score)/\(ChecklistCriterion.all.count)")
                    .font(.headline)
                    .monospacedDigit()
                    .foregroundStyle(recommendation.color)
                Text(recommendation.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContentView()
}
