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

    private var liveScore: Int {
        answers.filter { $0 }.count
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
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
                } header: {
                    SectionHeader(title: "Stock")
                }

                ForEach(ChecklistCriterion.Category.allCases, id: \.self) { category in
                    Section {
                        ForEach(ChecklistCriterion.all.indices.filter { ChecklistCriterion.all[$0].category == category }, id: \.self) { index in
                            CriterionToggle(criterion: ChecklistCriterion.all[index], isOn: $answers[index])
                        }
                    } header: {
                        SectionHeader(title: category.rawValue)
                    }
                }
            }
            .screenBackground()
            .safeAreaInset(edge: .bottom) {
                LiveScoreBar(score: liveScore)
            }
            .navigationTitle(evaluation == nil ? "New Evaluation" : "Edit Evaluation")
            .navigationBarTitleDisplayMode(.inline)
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
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(criterion.label)
                    if criterion.autoFillRule != nil {
                        Text("Auto-fill")
                            .font(.caption)
                            .foregroundStyle(.tint)
                    }
                }

                Spacer(minLength: 4)

                Button {
                    showingInfo = true
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.tint)
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

struct LiveScoreBar: View {
    let score: Int

    var body: some View {
        let recommendation = Recommendation(score: score)
        HStack {
            Text("Score")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(recommendation.title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("\(score)/\(ChecklistCriterion.all.count)")
                .font(.headline)
                .monospacedDigit()
                .foregroundStyle(recommendation.color)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.bar)
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
                Text("Auto-fill: \(rule)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(width: 280, alignment: .leading)
        .padding()
    }
}
