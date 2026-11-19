import SwiftUI
import SwiftData

struct EvaluationResultView: View {
    let evaluation: StockEvaluation
    @State private var pdfURL: URL?
    @State private var showingEdit = false

    var body: some View {
        let recommendation = Recommendation(score: evaluation.score)

        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(evaluation.score)")
                            .font(.system(size: 44, weight: .semibold))
                            .monospacedDigit()
                            .foregroundStyle(recommendation.color)
                        Text("/ \(ChecklistCriterion.all.count)")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    Text(recommendation.title)
                        .font(.headline)
                        .foregroundStyle(recommendation.color)
                    Text(evaluation.evaluationDate.formatted(date: .long, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }

            if !evaluation.notes.isEmpty {
                Section {
                    Text(evaluation.notes)
                } header: {
                    SectionHeader(title: "Notes")
                }
            }

            ForEach(ChecklistCriterion.Category.allCases, id: \.self) { category in
                let items = ChecklistCriterion.all.filter { $0.category == category }
                let passed = items.filter { evaluation[keyPath: $0.keyPath] }.count
                Section {
                    ForEach(items) { criterion in
                        CheckmarkRow(title: criterion.label, isChecked: evaluation[keyPath: criterion.keyPath])
                    }
                } header: {
                    HStack {
                        SectionHeader(title: category.rawValue)
                        Spacer()
                        Text("\(passed)/\(items.count)")
                            .monospacedDigit()
                    }
                }
            }
        }
        .screenBackground()
        .navigationTitle(evaluation.tickerSymbol)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") { showingEdit = true }
            }
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
        .sheet(isPresented: $showingEdit, onDismiss: generatePDF) {
            ChecklistView(evaluation: evaluation)
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

    private let textColor = Color(white: 0.1)
    private let mutedColor = Color(white: 0.45)

    var body: some View {
        let recommendation = Recommendation(score: evaluation.score)

        VStack(alignment: .leading, spacing: 0) {
            Text("TWENTY · STOCK EVALUATION")
                .font(.system(size: 9, weight: .semibold))
                .tracking(1)
                .foregroundStyle(mutedColor)

            Text(evaluation.tickerSymbol)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(textColor)
                .padding(.top, 6)

            Text(evaluation.evaluationDate.formatted(date: .long, time: .shortened))
                .font(.system(size: 10))
                .foregroundStyle(mutedColor)
                .padding(.top, 2)

            HStack(spacing: 40) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Score")
                        .font(.system(size: 9))
                        .foregroundStyle(mutedColor)
                    Text("\(evaluation.score) / \(ChecklistCriterion.all.count)")
                        .font(.system(size: 16, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(textColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Recommendation")
                        .font(.system(size: 9))
                        .foregroundStyle(mutedColor)
                    Text(recommendation.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(recommendation.color)
                }
            }
            .padding(.top, 18)

            if !evaluation.notes.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Notes")
                        .font(.system(size: 9))
                        .foregroundStyle(mutedColor)
                    Text(evaluation.notes)
                        .font(.system(size: 10))
                        .foregroundStyle(textColor)
                        .lineLimit(3)
                }
                .padding(.top, 14)
            }

            Rectangle()
                .fill(Color(white: 0.85))
                .frame(height: 0.5)
                .padding(.vertical, 16)

            VStack(alignment: .leading, spacing: 14) {
                ForEach(ChecklistCriterion.Category.allCases, id: \.self) { category in
                    let items = ChecklistCriterion.all.filter { $0.category == category }
                    let passed = items.filter { evaluation[keyPath: $0.keyPath] }.count
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(category.rawValue.uppercased())
                                .tracking(0.8)
                            Spacer()
                            Text("\(passed)/\(items.count)")
                                .monospacedDigit()
                        }
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(mutedColor)
                        .padding(.bottom, 2)

                        ForEach(items) { criterion in
                            let isChecked = evaluation[keyPath: criterion.keyPath]
                            HStack {
                                Text(criterion.label)
                                    .foregroundStyle(textColor)
                                Spacer()
                                Text(isChecked ? "Pass" : "—")
                                    .foregroundStyle(isChecked ? textColor : mutedColor)
                            }
                            .font(.system(size: 10.5))
                        }
                    }
                }
            }

            Spacer(minLength: 0)

            Text("Generated with Twenty")
                .font(.system(size: 8))
                .foregroundStyle(mutedColor)
        }
        .padding(48)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
    }
}

struct CheckmarkRow: View {
    let title: String
    let isChecked: Bool

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Image(systemName: isChecked ? "checkmark" : "minus")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isChecked ? Theme.positive : Color.secondary)
                .accessibilityLabel(isChecked ? "Passed" : "Not passed")
        }
    }
}
