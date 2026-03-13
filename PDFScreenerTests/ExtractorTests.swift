import XCTest
import PDFKit
@testable import PDF_Screener

final class ExtractorTests: XCTestCase {
    func testEmptyDocumentReturnsNoFields() {
        let doc = PDFDocument()
        let fields = PDFExtractor.extractFields(from: doc)
        XCTAssertTrue(fields.isEmpty)
    }

    func testPageWithNoAnnotationsReturnsNoFields() {
        let doc = PDFDocument()
        let page = PDFPage()
        doc.insert(page, at: 0)
        let fields = PDFExtractor.extractFields(from: doc)
        XCTAssertTrue(fields.isEmpty)
    }

    func testExtractsTextWidget() {
        let doc = PDFDocument()
        let page = PDFPage()
        doc.insert(page, at: 0)

        let widget = PDFAnnotation(bounds: CGRect(x: 0, y: 0, width: 200, height: 30), forType: .widget, withProperties: nil)
        widget.widgetFieldType = .text
        widget.fieldName = "fullName"
        widget.widgetStringValue = "John"
        page.addAnnotation(widget)

        let fields = PDFExtractor.extractFields(from: doc)
        XCTAssertEqual(fields.count, 1)
        XCTAssertEqual(fields.first?.name, "fullName")
        XCTAssertEqual(fields.first?.type, .text)
        XCTAssertEqual(fields.first?.currentValue, "John")
        XCTAssertEqual(fields.first?.page, 0)
    }

    func testExtractsCheckboxWidget() {
        let doc = PDFDocument()
        let page = PDFPage()
        doc.insert(page, at: 0)

        let widget = PDFAnnotation(bounds: CGRect(x: 0, y: 0, width: 20, height: 20), forType: .widget, withProperties: nil)
        widget.widgetFieldType = .button
        widget.fieldName = "agree"
        widget.widgetStringValue = "Yes"
        page.addAnnotation(widget)

        let fields = PDFExtractor.extractFields(from: doc)
        XCTAssertEqual(fields.count, 1)
        XCTAssertEqual(fields.first?.type, .checkbox)
        XCTAssertEqual(fields.first?.currentValue, "true")
    }

    func testExtractsChoiceWidget() {
        let doc = PDFDocument()
        let page = PDFPage()
        doc.insert(page, at: 0)

        let widget = PDFAnnotation(bounds: CGRect(x: 0, y: 0, width: 200, height: 30), forType: .widget, withProperties: nil)
        widget.widgetFieldType = .choice
        widget.fieldName = "country"
        widget.widgetStringValue = "Canada"
        widget.choices = ["Canada", "USA", "UK"]
        page.addAnnotation(widget)

        let fields = PDFExtractor.extractFields(from: doc)
        XCTAssertEqual(fields.count, 1)
        XCTAssertEqual(fields.first?.type, .dropdown)
        XCTAssertEqual(fields.first?.options, ["Canada", "USA", "UK"])
    }

    func testSkipsAnnotationsWithEmptyFieldName() {
        let doc = PDFDocument()
        let page = PDFPage()
        doc.insert(page, at: 0)

        let widget = PDFAnnotation(bounds: CGRect(x: 0, y: 0, width: 200, height: 30), forType: .widget, withProperties: nil)
        widget.widgetFieldType = .text
        widget.fieldName = ""
        page.addAnnotation(widget)

        let fields = PDFExtractor.extractFields(from: doc)
        XCTAssertTrue(fields.isEmpty)
    }

    func testMultiPageExtraction() {
        let doc = PDFDocument()
        let page0 = PDFPage()
        let page1 = PDFPage()
        doc.insert(page0, at: 0)
        doc.insert(page1, at: 1)

        let w0 = PDFAnnotation(bounds: CGRect(x: 0, y: 0, width: 200, height: 30), forType: .widget, withProperties: nil)
        w0.widgetFieldType = .text
        w0.fieldName = "name"
        page0.addAnnotation(w0)

        let w1 = PDFAnnotation(bounds: CGRect(x: 0, y: 0, width: 200, height: 30), forType: .widget, withProperties: nil)
        w1.widgetFieldType = .text
        w1.fieldName = "email"
        page1.addAnnotation(w1)

        let fields = PDFExtractor.extractFields(from: doc)
        XCTAssertEqual(fields.count, 2)
        XCTAssertEqual(fields[0].page, 0)
        XCTAssertEqual(fields[1].page, 1)
    }
}
