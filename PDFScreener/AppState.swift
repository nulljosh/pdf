import SwiftUI
import PDFKit
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var pdfDocument: PDFDocument?
    @Published var pdfURL: URL?
    @Published var fields: [FormField] = []
    @Published var showFileImporter = false
    @Published var statusMessage = "Drop a PDF or press Cmd+O"
    @Published var isProcessing = false

    func loadPDF(from url: URL) {
        guard let doc = PDFDocument(url: url) else {
            statusMessage = "Failed to open PDF"
            return
        }

        if doc.isEncrypted && !doc.unlock(withPassword: "") {
            statusMessage = "PDF is encrypted"
            return
        }

        pdfDocument = doc
        pdfURL = url
        fields = PDFExtractor.extractFields(from: doc)
        statusMessage = "Loaded \(url.lastPathComponent) -- \(fields.count) fields found"
    }

    func fillAndSave() {
        guard let doc = pdfDocument, let url = pdfURL else { return }

        isProcessing = true
        let answers = Dictionary(uniqueKeysWithValues: fields.map { ($0.name, $0.currentValue) })
        PDFFiller.fillFields(in: doc, with: answers)

        let stem = url.deletingPathExtension().lastPathComponent
        let outputURL = url.deletingLastPathComponent()
            .appendingPathComponent("\(stem)_filled.pdf")

        if doc.write(to: outputURL) {
            statusMessage = "Saved to \(outputURL.lastPathComponent)"
        } else {
            statusMessage = "Failed to save PDF"
        }
        isProcessing = false
    }

    func exportAnswersJSON() -> String {
        let answers = Dictionary(uniqueKeysWithValues: fields.map { ($0.name, $0.currentValue) })
        guard let data = try? JSONSerialization.data(
            withJSONObject: answers,
            options: [.prettyPrinted, .sortedKeys]
        ) else { return "{}" }
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}
