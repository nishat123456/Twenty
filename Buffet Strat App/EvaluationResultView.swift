import SwiftUI
import SwiftData

struct EvaluationResultView: View {
    let evaluation: StockEvaluation
    @State private var pdfURL: URL?
    
    var body: some View {
        Form {
            Section(header: Text("Overview")) {
                LabeledContent("Ticker", value: evaluation.tickerSymbol)
                LabeledContent("Date", value: evaluation.evaluationDate.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("Score", value: "\(evaluation.score) / 20")
            }
            if !evaluation.notes.isEmpty {
                Section(header: Text("Notes")) {
                    Text(evaluation.notes)
                }
            }
            Section(header: Text("Final Recommendation")) {
                let score = evaluation.score
                if score >= 16 {
                    Text("Strong Buy 🎯")
                        .foregroundColor(.green).font(.headline)
                } else if score >= 12 {
                    Text("Moderate Buy 🤔")
                        .foregroundColor(.orange).font(.headline)
                } else {
                    Text("Not Recommended 🚫")
                        .foregroundColor(.red).font(.headline)
                }
            }
            
            Section(header: Text("Criteria Checked")) {
                CheckmarkRow(title: "1. EPS yearly increases", isChecked: evaluation.epsYearlyIncreases)
                CheckmarkRow(title: "2. EPS rate of increase", isChecked: evaluation.epsRateOfIncrease)
                CheckmarkRow(title: "3. Predictability of Earnings", isChecked: evaluation.predictableEarnings)
                CheckmarkRow(title: "4. Yield", isChecked: evaluation.goodYield)
                CheckmarkRow(title: "5. ROE", isChecked: evaluation.goodROE)
                CheckmarkRow(title: "6. Cash Flow", isChecked: evaluation.strongCashFlow)
                CheckmarkRow(title: "7. Slope", isChecked: evaluation.positiveSlope)
                CheckmarkRow(title: "8. Debt to Equity Ratio", isChecked: evaluation.lowDebtToEquity)
                CheckmarkRow(title: "9. PE", isChecked: evaluation.reasonablePE)
                CheckmarkRow(title: "10. Insider Activity", isChecked: evaluation.positiveInsiderActivity)
                CheckmarkRow(title: "11. Consumer Monopoly", isChecked: evaluation.isConsumerMonopoly)
                CheckmarkRow(title: "12. Spin", isChecked: evaluation.positiveSpin)
                CheckmarkRow(title: "13. Analyst's Opinion", isChecked: evaluation.favorableAnalystOpinion)
                CheckmarkRow(title: "14. Fair Value", isChecked: evaluation.belowFairValue)
                CheckmarkRow(title: "15. Understandable Business", isChecked: evaluation.understandableBusiness)
                CheckmarkRow(title: "16. Takeover Target", isChecked: evaluation.potentialTakeoverTarget)
                CheckmarkRow(title: "17. Evolution not Revolution", isChecked: evaluation.isEvolutionaryNotRevolutionary)
                CheckmarkRow(title: "18. Great or good company", isChecked: evaluation.isGreatCompany)
                CheckmarkRow(title: "19. Good Investment Price", isChecked: evaluation.goodPricing)
                CheckmarkRow(title: "20. No Portfolio Duplication", isChecked: evaluation.noPortfolioDuplication)
            }
        }
        .navigationTitle(evaluation.tickerSymbol)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let url = pdfURL {
                    ShareLink(item: url) {
                        Image(systemName: "square.and.arrow.up")
                    }
                } else {
                    ProgressView()
                }
            }
        }
        .onAppear {
            generatePDF()
        }
    }
    
    @MainActor
    private func generatePDF() {
        let renderView = EvaluationReportPDFView(evaluation: evaluation)
            .frame(width: 612, height: 792) // Standard US Letter format
        
        let renderer = ImageRenderer(content: renderView)
        
        let path = URL.documentsDirectory.appending(path: "\(evaluation.tickerSymbol)-Evaluation.pdf")
        
        renderer.render { size, context in
            var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            guard let pdf = CGContext(path as CFURL, mediaBox: &box, nil) else { return }
            pdf.beginPDFPage(nil)
            context(pdf)
            pdf.endPDFPage()
            pdf.closePDF()
        }
        self.pdfURL = path
    }
}

struct EvaluationReportPDFView: View {
    let evaluation: StockEvaluation
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Buffet Strategy Checklist")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Evaluation: \(evaluation.tickerSymbol)")
                .font(.largeTitle).bold()
            
            Text("Date: \(evaluation.evaluationDate.formatted(date: .abbreviated, time: .shortened))")
            
            HStack {
                Text("App Score:").font(.title2)
                Text("\(evaluation.score) / 20").font(.title2).bold()
            }
            .padding(.top, 5)
            
            Divider()
            
            if !evaluation.notes.isEmpty {
                Text("Notes:").bold()
                Text(evaluation.notes).italic()
                Divider()
            }
            
            Text("Passed Criteria (✅):").bold()
            
            let passed = evaluation.passedCriteriaList()
            ForEach(passed, id: \.self) { c in
                Text("✅ \(c)")
                    .font(.subheadline)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Text("Generated by Buffet Strat App")
                    .font(.footnote)
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .padding(40)
        .background(Color.white)
    }
}

extension StockEvaluation {
    func passedCriteriaList() -> [String] {
        var list: [String] = []
        if epsYearlyIncreases { list.append("1. EPS yearly increases") }
        if epsRateOfIncrease { list.append("2. EPS rate of increase") }
        if predictableEarnings { list.append("3. Predictability of Earnings") }
        if goodYield { list.append("4. Good Yield") }
        if goodROE { list.append("5. Good ROE") }
        if strongCashFlow { list.append("6. Strong Cash Flow") }
        if positiveSlope { list.append("7. Positive Slope") }
        if lowDebtToEquity { list.append("8. Low Debt to Equity") }
        if reasonablePE { list.append("9. Reasonable PE") }
        if positiveInsiderActivity { list.append("10. Positive Insider Activity") }
        if isConsumerMonopoly { list.append("11. Consumer Monopoly") }
        if positiveSpin { list.append("12. Positive Spin") }
        if favorableAnalystOpinion { list.append("13. Favorable Analyst Opinion") }
        if belowFairValue { list.append("14. Below Fair Value") }
        if understandableBusiness { list.append("15. Understandable Business") }
        if potentialTakeoverTarget { list.append("16. Takeover Target") }
        if isEvolutionaryNotRevolutionary { list.append("17. Evolution not Revolution") }
        if isGreatCompany { list.append("18. Great / Good Company") }
        if goodPricing { list.append("19. Good Investment Price") }
        if noPortfolioDuplication { list.append("20. No Portfolio Duplication") }
        return list
    }
}

struct CheckmarkRow: View {
    let title: String
    let isChecked: Bool
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if isChecked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.red)
            }
        }
    }
}
