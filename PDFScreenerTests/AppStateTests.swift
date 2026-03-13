import XCTest
import PDFKit
@testable import PDF_Screener

@MainActor
final class AppStateTests: XCTestCase {
    func testInitialState() {
        let state = AppState()
        XCTAssertNil(state.pdfDocument)
        XCTAssertNil(state.pdfURL)
        XCTAssertTrue(state.fields.isEmpty)
        XCTAssertFalse(state.isProcessing)
        XCTAssertEqual(state.statusMessage, "Drop a PDF or press Cmd+O")
    }

    func testLoadPDFWithBadURLSetsError() {
        let state = AppState()
        let badURL = URL(fileURLWithPath: "/nonexistent/fake.pdf")
        state.loadPDF(from: badURL)
        XCTAssertEqual(state.statusMessage, "Failed to open PDF")
        XCTAssertNil(state.pdfDocument)
    }

    func testExportAnswersJSONWithNoFields() {
        let state = AppState()
        let json = state.exportAnswersJSON()
        XCTAssertEqual(json.trimmingCharacters(in: .whitespacesAndNewlines), "{\n\n}")
    }

    func testExportAnswersJSONWithFields() {
        let state = AppState()
        state.fields = [
            FormField(name: "city", type: .text, currentValue: "Vancouver", page: 0, options: nil, annotation: nil),
            FormField(name: "agree", type: .checkbox, currentValue: "true", page: 0, options: nil, annotation: nil)
        ]
        let json = state.exportAnswersJSON()
        let data = json.data(using: .utf8)!
        let parsed = try! JSONSerialization.jsonObject(with: data) as! [String: String]
        XCTAssertEqual(parsed["city"], "Vancouver")
        XCTAssertEqual(parsed["agree"], "true")
    }

    func testLoadValidPDF() {
        let state = AppState()
        // Create a temporary PDF
        let tmpDir = FileManager.default.temporaryDirectory
        let pdfURL = tmpDir.appendingPathComponent("test_appstate.pdf")
        let doc = PDFDocument()
        let page = PDFPage()
        doc.insert(page, at: 0)
        doc.write(to: pdfURL)

        state.loadPDF(from: pdfURL)
        XCTAssertNotNil(state.pdfDocument)
        XCTAssertEqual(state.pdfURL, pdfURL)
        XCTAssertTrue(state.statusMessage.contains("test_appstate.pdf"))

        try? FileManager.default.removeItem(at: pdfURL)
    }
}
