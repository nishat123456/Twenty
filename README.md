# Twenty

*Twenty questions before you buy.*

Twenty is an iOS app for evaluating stocks with a 20-point value investing checklist based on Warren Buffett's principles. Answer the questions for a stock, get a score out of 20 with a recommendation, and export the result as a PDF report.

## Features

- 20-question checklist grouped into Financials, Company & Market, and Qualitative Checks
- A plain-English explanation for every question
- Auto-fill for 6 financial questions using market data from Financial Modeling Prep
- Live score and recommendation while answering
- Saved evaluations that can be edited later
- PDF report export

## Scoring

Each question answered "yes" adds one point.

| Score | Recommendation |
|---|---|
| 16–20 | Strong Buy |
| 12–15 | Moderate Buy |
| 0–11 | Not Recommended |

## Auto-fill

Auto-fill looks up the ticker and answers six questions automatically. The other 14 are answered by the user.

| # | Question | Rule |
|---|---|---|
| 1 | EPS yearly increases | EPS rose every year for the last 5 years |
| 2 | EPS rate of increase | EPS grew at least 10% per year on average over 5 years |
| 4 | Yield | Dividend yield above 2% |
| 5 | ROE | Return on equity above 15% |
| 8 | Debt to Equity Ratio | Below 0.5 |
| 9 | PE | Price-to-earnings ratio between 0 and 15 |

## Requirements

- Xcode 26 or later
- iOS 26.2 or later
- A free [Financial Modeling Prep](https://financialmodelingprep.com) API key (only needed for Auto-fill)

## Running the app

1. Clone the repository and open `Buffet Strat App.xcodeproj` in Xcode.
2. Choose an iPhone simulator and press Run (⌘R).
3. To use Auto-fill, open Settings in the app and enter your API key.

## Project structure

| File | Purpose |
|---|---|
| `TwentyApp.swift` | App entry point and data storage setup |
| `LandingView.swift` | Welcome screen shown at launch |
| `ContentView.swift` | List of saved evaluations |
| `ChecklistView.swift` | Form for creating and editing evaluations, including Auto-fill |
| `ChecklistCriteria.swift` | The 20 questions, their explanations, and Auto-fill rules |
| `EvaluationResultView.swift` | Evaluation details and PDF report |
| `SettingsView.swift` | API key and app information |
| `StockEvaluation.swift` | Saved evaluation data model (SwiftData) |
| `APIService.swift` | Financial Modeling Prep requests |
| `Components.swift`, `Theme.swift` | Shared recommendation logic and colors |

## Data and privacy

Evaluations and the API key are stored only on the device. The app sends the ticker symbol and API key to Financial Modeling Prep when Auto-fill is used, and does not collect any other data.

## References

- `stock-checklist.pdf`: the 20-point checklist the app is based on
- `Investing Seminar 1998.PDF`: seminar notes used as background for the checklist

## Disclaimer

Twenty is an educational project built for an iOS app development class. It is not financial advice.

## Project team

- Om Nepal
- M M Nishat
- Arjun Pun Magar
