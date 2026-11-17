import Foundation
import SwiftUI

class APIService {
    static let shared = APIService()

    @AppStorage("fmp_api_key") var apiKey: String = ""

    private let baseURL = "https://financialmodelingprep.com/stable"

    struct Fundamentals {
        let epsHistory: [Double]  // Annual EPS, oldest year first
        let pe: Double?
        let returnOnEquity: Double?
        let debtToEquity: Double?
        let dividendYield: Double?
    }

    nonisolated private struct RatiosTTM: Decodable {
        let priceToEarningsRatioTTM: Double?
        let debtToEquityRatioTTM: Double?
        let dividendYieldTTM: Double?
    }

    nonisolated private struct KeyMetricsTTM: Decodable {
        let returnOnEquityTTM: Double?
    }

    nonisolated private struct IncomeStatement: Decodable {
        let date: String
        let eps: Double?
    }

    func fetchFundamentals(for ticker: String) async throws -> Fundamentals? {
        async let ratiosRequest: [RatiosTTM] = fetch("ratios-ttm", ticker: ticker)
        async let metricsRequest: [KeyMetricsTTM] = fetch("key-metrics-ttm", ticker: ticker)
        async let incomeRequest: [IncomeStatement] = fetch("income-statement", ticker: ticker,
                                                           extraQuery: [URLQueryItem(name: "period", value: "annual"),
                                                                        URLQueryItem(name: "limit", value: "5")])
        let (ratiosList, metricsList, statements) = try await (ratiosRequest, metricsRequest, incomeRequest)
        let ratios = ratiosList.first
        let metrics = metricsList.first

        if ratios == nil && metrics == nil && statements.isEmpty { return nil }

        let epsHistory = statements
            .sorted { $0.date < $1.date }
            .compactMap { $0.eps }

        return Fundamentals(epsHistory: epsHistory,
                            pe: ratios?.priceToEarningsRatioTTM,
                            returnOnEquity: metrics?.returnOnEquityTTM,
                            debtToEquity: ratios?.debtToEquityRatioTTM,
                            dividendYield: ratios?.dividendYieldTTM)
    }

    private func fetch<T: Decodable>(_ endpoint: String, ticker: String, extraQuery: [URLQueryItem] = []) async throws -> [T] {
        guard !apiKey.isEmpty else { throw NSError(domain: "APIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "API Key is missing."]) }

        var components = URLComponents(string: "\(baseURL)/\(endpoint)")
        components?.queryItems = [
            URLQueryItem(name: "symbol", value: ticker),
            URLQueryItem(name: "apikey", value: apiKey)
        ] + extraQuery
        guard let url = components?.url else { throw URLError(.badURL) }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([T].self, from: data)
    }
}
