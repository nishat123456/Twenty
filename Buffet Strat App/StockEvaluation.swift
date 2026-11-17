import Foundation
import SwiftData

@Model
final class StockEvaluation {
    var id: UUID
    var tickerSymbol: String
    var evaluationDate: Date
    var notes: String
    
    // Checklist Criteria (20 items)
    var epsYearlyIncreases: Bool // 1. EPS - yearly increases (5 years)
    var epsRateOfIncrease: Bool  // 2. EPS - rate of increase (5 years)
    var predictableEarnings: Bool // 3. Predictability of Earnings
    var goodYield: Bool          // 4. Yield
    var goodROE: Bool            // 5. ROE
    var strongCashFlow: Bool     // 6. Cash Flow
    var positiveSlope: Bool      // 7. Slope
    var lowDebtToEquity: Bool    // 8. Debt to Equity Ratio
    var reasonablePE: Bool       // 9. PE
    var positiveInsiderActivity: Bool // 10. Insider Activity
    var isConsumerMonopoly: Bool // 11. Consumer Monopoly
    var positiveSpin: Bool       // 12. Spin
    var favorableAnalystOpinion: Bool // 13. Analyst's Opinion
    var belowFairValue: Bool     // 14. Fair Value
    var understandableBusiness: Bool // 15. Understandable Business
    var potentialTakeoverTarget: Bool // 16. Takeover Target
    var isEvolutionaryNotRevolutionary: Bool // 17. Evolution not Revolution
    var isGreatCompany: Bool     // 18. Great or good company
    var goodPricing: Bool        // 19. Good Investment Price
    var noPortfolioDuplication: Bool // 20. No Portfolio Duplication
    
    init(tickerSymbol: String) {
        self.id = UUID()
        self.tickerSymbol = tickerSymbol
        self.evaluationDate = Date()
        self.notes = ""
        self.epsYearlyIncreases = false
        self.epsRateOfIncrease = false
        self.predictableEarnings = false
        self.goodYield = false
        self.goodROE = false
        self.strongCashFlow = false
        self.positiveSlope = false
        self.lowDebtToEquity = false
        self.reasonablePE = false
        self.positiveInsiderActivity = false
        self.isConsumerMonopoly = false
        self.positiveSpin = false
        self.favorableAnalystOpinion = false
        self.belowFairValue = false
        self.understandableBusiness = false
        self.potentialTakeoverTarget = false
        self.isEvolutionaryNotRevolutionary = false
        self.isGreatCompany = false
        self.goodPricing = false
        self.noPortfolioDuplication = false
    }
    
    var score: Int {
        ChecklistCriterion.all.filter { self[keyPath: $0.keyPath] }.count
    }
}
