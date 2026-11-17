import Foundation

struct ChecklistCriterion: Identifiable {
    enum Category: String, CaseIterable {
        case financials = "Financials"
        case companyAndMarket = "Company & Market"
        case qualitative = "Qualitative Checks"
    }

    let number: Int
    let title: String
    let category: Category
    let explanation: String
    let autoFillRule: String?
    let keyPath: ReferenceWritableKeyPath<StockEvaluation, Bool>

    var id: Int { number }
    var label: String { "\(number). \(title)" }

    static let all: [ChecklistCriterion] = [
        ChecklistCriterion(number: 1, title: "EPS yearly increases (5 yrs)", category: .financials,
                           explanation: "Earnings per share (EPS) = (net income − preferred dividends) ÷ shares outstanding. Did EPS rise every year for the last 5 years?",
                           autoFillRule: "On if EPS rose every year for 5 years.",
                           keyPath: \.epsYearlyIncreases),
        ChecklistCriterion(number: 2, title: "EPS rate of increase (5 yrs)", category: .financials,
                           explanation: "How fast EPS grew over 5 years, measured as ending EPS ÷ beginning EPS.",
                           autoFillRule: "On if EPS grew at least 10% per year on average.",
                           keyPath: \.epsRateOfIncrease),
        ChecklistCriterion(number: 3, title: "Predictability of Earnings", category: .financials,
                           explanation: "Are earnings steady and easy to forecast, without big swings or losses?",
                           autoFillRule: nil,
                           keyPath: \.predictableEarnings),
        ChecklistCriterion(number: 4, title: "Yield", category: .financials,
                           explanation: "Dividend yield = yearly dividend ÷ share price. How much the stock pays you each year for owning it.",
                           autoFillRule: "On if the dividend yield is above 2%.",
                           keyPath: \.goodYield),
        ChecklistCriterion(number: 5, title: "ROE", category: .financials,
                           explanation: "Return on equity = net income ÷ owners' equity. How well the company turns owners' money into profit.",
                           autoFillRule: "On if ROE is above 15%.",
                           keyPath: \.goodROE),
        ChecklistCriterion(number: 6, title: "Cash Flow", category: .financials,
                           explanation: "Cash flow = net income + non-cash charges such as depreciation. Does the business bring in real cash consistently?",
                           autoFillRule: nil,
                           keyPath: \.strongCashFlow),
        ChecklistCriterion(number: 7, title: "Slope", category: .financials,
                           explanation: "Is the long-term trend of the stock's chart pointing upward?",
                           autoFillRule: nil,
                           keyPath: \.positiveSlope),
        ChecklistCriterion(number: 8, title: "Debt to Equity Ratio", category: .financials,
                           explanation: "Long-term debt ÷ owners' equity. A low ratio means conservative, low-risk financing. A high ratio means aggressive financing.",
                           autoFillRule: "On if the ratio is below 0.5.",
                           keyPath: \.lowDebtToEquity),
        ChecklistCriterion(number: 9, title: "PE", category: .financials,
                           explanation: "Price-to-earnings ratio = share price ÷ EPS. How much you pay for each $1 of yearly profit.",
                           autoFillRule: "On if P/E is between 0 and 15.",
                           keyPath: \.reasonablePE),
        ChecklistCriterion(number: 10, title: "Insider Activity", category: .companyAndMarket,
                           explanation: "Are company executives and directors buying shares (a good sign) rather than selling them?",
                           autoFillRule: nil,
                           keyPath: \.positiveInsiderActivity),
        ChecklistCriterion(number: 11, title: "Consumer Monopoly", category: .companyAndMarket,
                           explanation: "Does the company have a strong brand or market position that competitors can't easily copy?",
                           autoFillRule: nil,
                           keyPath: \.isConsumerMonopoly),
        ChecklistCriterion(number: 12, title: "Spin", category: .companyAndMarket,
                           explanation: "Is the company's public image and news coverage favorable?",
                           autoFillRule: nil,
                           keyPath: \.positiveSpin),
        ChecklistCriterion(number: 13, title: "Analyst's Opinion", category: .companyAndMarket,
                           explanation: "Do professional analysts mostly rate the stock a buy?",
                           autoFillRule: nil,
                           keyPath: \.favorableAnalystOpinion),
        ChecklistCriterion(number: 14, title: "Fair Value", category: .companyAndMarket,
                           explanation: "Is the stock trading below what you believe it's really worth?",
                           autoFillRule: nil,
                           keyPath: \.belowFairValue),
        ChecklistCriterion(number: 15, title: "Understandable Business", category: .qualitative,
                           explanation: "Can you explain how the company makes money in a sentence or two?",
                           autoFillRule: nil,
                           keyPath: \.understandableBusiness),
        ChecklistCriterion(number: 16, title: "Takeover Target", category: .qualitative,
                           explanation: "Could a bigger company want to buy it, usually at a higher price than today?",
                           autoFillRule: nil,
                           keyPath: \.potentialTakeoverTarget),
        ChecklistCriterion(number: 17, title: "Evolution not Revolution", category: .qualitative,
                           explanation: "Does the company improve steadily instead of betting on risky, unproven changes?",
                           autoFillRule: nil,
                           keyPath: \.isEvolutionaryNotRevolutionary),
        ChecklistCriterion(number: 18, title: "Great or Good Company", category: .qualitative,
                           explanation: "Would you be happy owning this company for 10 years or more?",
                           autoFillRule: nil,
                           keyPath: \.isGreatCompany),
        ChecklistCriterion(number: 19, title: "Good Investment Price", category: .qualitative,
                           explanation: "Have you set the highest price you'd pay, and is the current price at or below it?",
                           autoFillRule: nil,
                           keyPath: \.goodPricing),
        ChecklistCriterion(number: 20, title: "No Portfolio Duplication", category: .qualitative,
                           explanation: "Does it add something new to your portfolio rather than overlap stocks you already own?",
                           autoFillRule: nil,
                           keyPath: \.noPortfolioDuplication)
    ]
}
