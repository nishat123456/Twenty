import SwiftUI
import SwiftData

struct ChecklistView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var tickerSymbol: String = ""
    @State private var notes: String = ""
    @State private var isLoading = false
    
    @State private var epsYearlyIncreases = false
    @State private var epsRateOfIncrease = false
    @State private var predictableEarnings = false
    @State private var goodYield = false
    @State private var goodROE = false
    @State private var strongCashFlow = false
    @State private var positiveSlope = false
    @State private var lowDebtToEquity = false
    @State private var reasonablePE = false
    @State private var positiveInsiderActivity = false
    @State private var isConsumerMonopoly = false
    @State private var positiveSpin = false
    @State private var favorableAnalystOpinion = false
    @State private var belowFairValue = false
    @State private var understandableBusiness = false
    @State private var potentialTakeoverTarget = false
    @State private var isEvolutionaryNotRevolutionary = false
    @State private var isGreatCompany = false
    @State private var goodPricing = false
    @State private var noPortfolioDuplication = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Stock Info")) {
                    HStack {
                        TextField("Ticker Symbol", text: $tickerSymbol)
#if os(iOS)
                            .autocapitalization(.allCharacters)
#endif
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
                            .disabled(tickerSymbol.isEmpty)
                        }
                    }
                    TextField("Notes", text: $notes, axis: .vertical)
                }
                
                Section(header: Text("Financials")) {
                    Toggle("1. EPS - yearly increases (5 yrs)", isOn: $epsYearlyIncreases)
                    Toggle("2. EPS - rate of increase (5 yrs)", isOn: $epsRateOfIncrease)
                    Toggle("3. Predictability of Earnings", isOn: $predictableEarnings)
                    Toggle("4. Yield", isOn: $goodYield)
                    Toggle("5. ROE", isOn: $goodROE)
                    Toggle("6. Cash Flow", isOn: $strongCashFlow)
                    Toggle("7. Slope", isOn: $positiveSlope)
                    Toggle("8. Debt to Equity Ratio", isOn: $lowDebtToEquity)
                    Toggle("9. PE", isOn: $reasonablePE)
                }
                
                Section(header: Text("Company & Market")) {
                    Toggle("10. Insider Activity", isOn: $positiveInsiderActivity)
                    Toggle("11. Consumer Monopoly", isOn: $isConsumerMonopoly)
                    Toggle("12. Spin", isOn: $positiveSpin)
                    Toggle("13. Analyst's Opinion", isOn: $favorableAnalystOpinion)
                    Toggle("14. Fair Value", isOn: $belowFairValue)
                }
                
                Section(header: Text("Qualitative Checks")) {
                    Toggle("15. Understandable Business", isOn: $understandableBusiness)
                    Toggle("16. Takeover Target", isOn: $potentialTakeoverTarget)
                    Toggle("17. Evolution not Revolution", isOn: $isEvolutionaryNotRevolutionary)
                    Toggle("18. Great or good company?", isOn: $isGreatCompany)
                    Toggle("19. Good Investment Price?", isOn: $goodPricing)
                    Toggle("20. No Portfolio Duplication?", isOn: $noPortfolioDuplication)
                }
            }
            .navigationTitle("New Evaluation")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEvaluation()
                    }
                    .disabled(tickerSymbol.isEmpty)
                }
            }
        }
    }
    
    private func saveEvaluation() {
        let evaluation = StockEvaluation(tickerSymbol: tickerSymbol)
        evaluation.notes = notes
        evaluation.epsYearlyIncreases = epsYearlyIncreases
        evaluation.epsRateOfIncrease = epsRateOfIncrease
        evaluation.predictableEarnings = predictableEarnings
        evaluation.goodYield = goodYield
        evaluation.goodROE = goodROE
        evaluation.strongCashFlow = strongCashFlow
        evaluation.positiveSlope = positiveSlope
        evaluation.lowDebtToEquity = lowDebtToEquity
        evaluation.reasonablePE = reasonablePE
        evaluation.positiveInsiderActivity = positiveInsiderActivity
        evaluation.isConsumerMonopoly = isConsumerMonopoly
        evaluation.positiveSpin = positiveSpin
        evaluation.favorableAnalystOpinion = favorableAnalystOpinion
        evaluation.belowFairValue = belowFairValue
        evaluation.understandableBusiness = understandableBusiness
        evaluation.potentialTakeoverTarget = potentialTakeoverTarget
        evaluation.isEvolutionaryNotRevolutionary = isEvolutionaryNotRevolutionary
        evaluation.isGreatCompany = isGreatCompany
        evaluation.goodPricing = goodPricing
        evaluation.noPortfolioDuplication = noPortfolioDuplication
        
        modelContext.insert(evaluation)
        dismiss()
    }
    
    private func autofill() async {
        guard !tickerSymbol.isEmpty else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            if let quote = try await APIService.shared.fetchQuote(for: tickerSymbol) {
                if let pe = quote.pe {
                    reasonablePE = pe < 15 && pe > 0
                }
                if let eps = quote.eps {
                    epsYearlyIncreases = eps > 0 // Basic assumption for trailing, just a heuristic
                }
            }
            
            if let metrics = try await APIService.shared.fetchKeyMetrics(for: tickerSymbol) {
                if let roe = metrics.returnOnEquityTTM {
                    goodROE = roe > 0.15
                }
                if let debtEquity = metrics.debtToEquityTTM {
                    lowDebtToEquity = debtEquity < 0.5 && debtEquity > 0
                }
                if let yield = metrics.dividendYieldTTM {
                    goodYield = yield > 0.02
                }
            }
        } catch {
            print("Failed to autofill: \(error)")
        }
    }
}
