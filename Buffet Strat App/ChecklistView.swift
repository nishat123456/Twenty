import SwiftUI
import SwiftData

struct ChecklistView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let evaluation: StockEvaluation?

    @State private var tickerSymbol: String
    @State private var notes: String
    @State private var answers: [Bool]
    @State private var isLoading = false

    init(evaluation: StockEvaluation? = nil) {
        self.evaluation = evaluation
        _tickerSymbol = State(initialValue: evaluation?.tickerSymbol ?? "")
        _notes = State(initialValue: evaluation?.notes ?? "")
        _answers = State(initialValue: ChecklistCriterion.all.map { evaluation?[keyPath: $0.keyPath] ?? false })
    }

    private var normalizedTicker: String {
        tickerSymbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Stock Info")) {
                    HStack {
                        TextField("Ticker Symbol", text: $tickerSymbol)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                        Spacer()
                        if isLoading {
                            ProgressView()
                        } else {
                            Button("Auto-fill") {
                                Task {
                                    await autofill()
                                }
                            }
                            .buttonStyle(.bordered)
                            .disabled(normalizedTicker.isEmpty)
                        }
                    }
                    TextField("Notes", text: $notes, axis: .vertical)
                }

                ForEach(ChecklistCriterion.Category.allCases, id: \.self) { category in
                    Section(header: Text(category.rawValue)) {
                        ForEach(ChecklistCriterion.all.indices.filter { ChecklistCriterion.all[$0].category == category }, id: \.self) { index in
                            CriterionToggle(criterion: ChecklistCriterion.all[index], isOn: $answers[index])
                        }
                    }
                }
            }
            .navigationTitle(evaluation == nil ? "New Evaluation" : "Edit Evaluation")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEvaluation()
                    }
                    .disabled(normalizedTicker.isEmpty)
                }
            }
        }
    }

    private func saveEvaluation() {
        let target = evaluation ?? StockEvaluation(tickerSymbol: normalizedTicker)
        target.tickerSymbol = normalizedTicker
        target.notes = notes
        for (index, criterion) in ChecklistCriterion.all.enumerated() {
            target[keyPath: criterion.keyPath] = answers[index]
        }

        if evaluation == nil {
            modelContext.insert(target)
        }
        dismiss()
    }

    private func setAnswer(_ keyPath: ReferenceWritableKeyPath<StockEvaluation, Bool>, _ value: Bool) {
        if let index = ChecklistCriterion.all.firstIndex(where: { $0.keyPath == keyPath }) {
            answers[index] = value
        }
    }

    private func autofill() async {
        let ticker = normalizedTicker
        guard !ticker.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            if let data = try await APIService.shared.fetchFundamentals(for: ticker) {
                if let pe = data.pe {
                    setAnswer(\.reasonablePE, pe < 15 && pe > 0)
                }
                if let rules = Self.epsRules(for: data.epsHistory) {
                    setAnswer(\.epsYearlyIncreases, rules.risesEveryYear)
                    setAnswer(\.epsRateOfIncrease, rules.growsTenPercentPerYear)
                }
                if let roe = data.returnOnEquity {
                    setAnswer(\.goodROE, roe > 0.15)
                }
                if let debtEquity = data.debtToEquity {
                    setAnswer(\.lowDebtToEquity, debtEquity < 0.5 && debtEquity > 0)
                }
                if let yield = data.dividendYield {
                    setAnswer(\.goodYield, yield > 0.02)
                }
            }
        } catch {
            print("Failed to autofill: \(error)")
        }
    }

    // Needs 5 years of EPS, oldest first. Returns nil when there isn't enough data.
    static func epsRules(for history: [Double]) -> (risesEveryYear: Bool, growsTenPercentPerYear: Bool)? {
        guard history.count >= 5 else { return nil }
        let eps = Array(history.suffix(5))

        let risesEveryYear = zip(eps, eps.dropFirst()).allSatisfy { $1 > $0 }

        var growsTenPercentPerYear = false
        if let first = eps.first, let last = eps.last, first > 0, last > 0 {
            let years = Double(eps.count - 1)
            let annualGrowth = pow(last / first, 1 / years) - 1
            growsTenPercentPerYear = annualGrowth >= 0.10
        }

        return (risesEveryYear, growsTenPercentPerYear)
    }
}

struct CriterionToggle: View {
    let criterion: ChecklistCriterion
    @Binding var isOn: Bool
    @State private var showingInfo = false

    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 6) {
                Text(criterion.label)
                if criterion.autoFillRule != nil {
                    Text("Auto")
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .foregroundStyle(Color.accentColor)
                        .background(Color.accentColor.opacity(0.15), in: Capsule())
                }
                Button {
                    showingInfo = true
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("About \(criterion.title)")
                .popover(isPresented: $showingInfo) {
                    CriterionInfoView(criterion: criterion)
                        .presentationCompactAdaptation(.popover)
                }
            }
        }
    }
}

struct CriterionInfoView: View {
    let criterion: ChecklistCriterion

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(criterion.label)
                .font(.headline)
            Text(criterion.explanation)
                .font(.subheadline)
            if let rule = criterion.autoFillRule {
                Label("Auto-fill: \(rule)", systemImage: "wand.and.stars")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: 280, alignment: .leading)
        .padding()
    }
}
