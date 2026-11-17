import Foundation
import SwiftUI

class APIService {
    static let shared = APIService()

    @AppStorage("fmp_api_key") var apiKey: String = ""

    private let baseURL = "https://financialmodelingprep.com/stable"

    struct Fundamentals {
        let eps: Double?
        let pe: Double?
        let returnOnEquity: Double?
        let debtToEquity: Double?
        let dividendYield: Double?
    }

    nonisolated private struct RatiosTTM: Decodable {
        let priceToEarningsRatioTTM: Double?
        let netIncomePerShareTTM: Double?
        let debtToEquityRatioTTM: Double?
        let dividendYieldTTM: Double?
    }

    nonisolated private struct KeyMetricsTTM: Decodable {
        let returnOnEquityTTM: Double?
    }

    func fetchFundamentals(for ticker: String) async throws -> Fundamentals? {
        async let ratiosRequest: RatiosTTM? = fetchFirst("ratios-ttm", ticker: ticker)
        async let metricsRequest: KeyMetricsTTM? = fetchFirst("key-metrics-ttm", ticker: ticker)
        let (ratios, metrics) = try await (ratiosRequest, metricsRequest)

        if ratios == nil && metrics == nil { return nil }
        return Fundamentals(eps: ratios?.netIncomePerShareTTM,
                            pe: ratios?.priceToEarningsRatioTTM,
                            returnOnEquity: metrics?.returnOnEquityTTM,
                            debtToEquity: ratios?.debtToEquityRatioTTM,
                            dividendYield: ratios?.dividendYieldTTM)
    }

    private func fetchFirst<T: Decodable>(_ endpoint: String, ticker: String) async throws -> T? {
        guard !apiKey.isEmpty else { throw NSError(domain: "APIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "API Key is missing."]) }

        var components = URLComponents(string: "\(baseURL)/\(endpoint)")
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: ticker),
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
