import Foundation
import SwiftUI

class APIService {
    static let shared = APIService()
    
    @AppStorage("fmp_api_key") var apiKey: String = ""
    
    struct QuoteResponse: Decodable {
        let symbol: String
        let price: Double?
        let eps: Double?
        let pe: Double?
    }
    
    struct KeyMetricsResponse: Decodable {
        let returnOnEquityTTM: Double?
        let debtToEquityTTM: Double?
        let dividendYieldTTM: Double?
    }
    
    func fetchQuote(for ticker: String) async throws -> QuoteResponse? {
        guard !apiKey.isEmpty else { throw NSError(domain: "APIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "API Key is missing."]) }
        guard let url = URL(string: "https://financialmodelingprep.com/api/v3/quote/\(ticker)?apikey=\(apiKey)") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let quotes = try decoder.decode([QuoteResponse].self, from: data)
        return quotes.first
    }
    
    func fetchKeyMetrics(for ticker: String) async throws -> KeyMetricsResponse? {
        guard !apiKey.isEmpty else { throw NSError(domain: "APIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "API Key is missing."]) }
        guard let url = URL(string: "https://financialmodelingprep.com/api/v3/key-metrics-ttm/\(ticker)?apikey=\(apiKey)") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let metrics = try decoder.decode([KeyMetricsResponse].self, from: data)
        return metrics.first
    }
}
