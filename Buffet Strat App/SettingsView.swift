import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("fmp_api_key") private var apiKey: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("API Configuration"), footer: Text("Get a free API key at financialmodelingprep.com. This is required to auto-fill financial metrics.")) {
                    SecureField("FMP API Key", text: $apiKey)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
