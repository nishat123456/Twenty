import Foundation
import SwiftUI

class APIService {
    static let shared = APIService()

    @AppStorage("fmp_api_key") var apiKey: String = ""

    // FMP retired its /api/v3/ endpoints for accounts created after Aug 31, 2025.
    // These calls use the current /stable/ endpoints instead.
    private let baseURL = "https://financialmodelingprep.com/stable"

    struct QuoteResponse {
        let symbol: String
        let eps: Double?
        let pe: Double?
    }

    struct KeyMetricsResponse {
        let returnOnEquityTTM: Double?
        let debtToEquityTTM: Double?
        let dividendYieldTTM: Double?
    }

    // Raw shapes returned by the /stable/ endpoints
    private struct RatiosTTM: Decodable {
        let symbol: String
        let priceToEarningsRatioTTM: Double?
        let netIncomePerShareTTM: Double?
        let debtToEquityRatioTTM: Double?
        let dividendYieldTTM: Double?
    }

    private struct KeyMetricsTTM: Decodable {
        let returnOnEquityTTM: Double?
    }

    func fetchQuote(for ticker: String) async throws -> QuoteResponse? {
        guard let ratios: RatiosTTM = try await fetchFirst("ratios-ttm", ticker: ticker) else { return nil }
        return QuoteResponse(symbol: ratios.symbol,
                             eps: ratios.netIncomePerShareTTM,
                             pe: ratios.priceToEarningsRatioTTM)
    }

    func fetchKeyMetrics(for ticker: String) async throws -> KeyMetricsResponse? {
        let metrics: KeyMetricsTTM? = try await fetchFirst("key-metrics-ttm", ticker: ticker)
        let ratios: RatiosTTM? = try await fetchFirst("ratios-ttm", ticker: ticker)
        if metrics == nil && ratios == nil { return nil }
        return KeyMetricsResponse(returnOnEquityTTM: metrics?.returnOnEquityTTM,
                                  debtToEquityTTM: ratios?.debtToEquityRatioTTM,
                                  dividendYieldTTM: ratios?.dividendYieldTTM)
    }

    /// Calls `<baseURL>/<endpoint>?symbol=<ticker>&apikey=<key>` and returns the first element of the JSON array.
    private func fetchFirst<T: Decodable>(_ endpoint: String, ticker: String) async throws -> T? {
        guard !apiKey.isEmpty else { throw NSError(domain: "APIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "API Key is missing."]) }

        var components = URLComponents(string: "\(baseURL)/\(endpoint)")
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: ticker.trimmingCharacters(in: .whitespaces).uppercased()),
            URLQueryItem(name: "apikey", value: apiKey)
        ]
        guard let url = components?.url else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([T].self, from: data).first
    }
}
