import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("fmp_api_key") private var apiKey: String = ""

    private let teamMembers = ["Om Nepal", "M M Nishat", "Arjun Pun Magar"]

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("FMP API Key", text: $apiKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Link("Get a Free API Key", destination: URL(string: "https://financialmodelingprep.com")!)
                } header: {
                    SectionHeader(title: "API Key")
                } footer: {
                    Text(apiKey.isEmpty
                         ? "Auto-fill uses Financial Modeling Prep to answer 6 of the 20 questions with market data."
                         : "Key saved on this device.")
                }

                Section {
                    LabeledContent("App", value: "Twenty")
                    LabeledContent("Version", value: appVersion)
                } header: {
                    SectionHeader(title: "About")
                }

                Section {
                    ForEach(teamMembers, id: \.self) { name in
                        Text(name)
                    }
                } header: {
                    SectionHeader(title: "Team")
                }
            }
            .screenBackground()
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
