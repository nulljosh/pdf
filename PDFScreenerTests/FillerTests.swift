import XCTest
import PDFKit
@testable import PDF_Screener

final class FillerTests: XCTestCase {
    func testFillEmptyDocumentNoCrash() {
        let doc = PDFDocument()
        PDFFiller.fillFields(in: doc, with: ["anything": "value"])
        // Should not crash
    }

    func testFillSetsTextWidgetValue() {
        let doc = PDFDocument()
        let page = PDFPage()
        doc.insert(page, at: 0)

        let widget = PDFAnnotation(bounds: CGRect(x: 0, y: 0, width: 200, height: 30), forType: .widget, withProperties: nil)
        widget.widgetFieldType = .text
        widget.fieldName = "city"
        widget.widgetStringValue = ""
        page.addAnnotation(widget)

        PDFFiller.fillFields(in: doc, with: ["city": "Vancouver"])
        XCTAssertEqual(widget.widgetStringValue, "Vancouver")
    }

    func testFillSetsCheckboxTrue() {
        let doc = PDFDocument()
        let page = PDFPage()
        doc.insert(page, at: 0)

        let widget = PDFAnnotation(bounds: CGRect(x: 0, y: 0, width: 20, height: 20), forType: .widget, withProperties: nil)
        widget.widgetFieldType = .button
        widget.fieldName = "agree"
        widget.widgetStringValue = "Off"
        page.addAnnotation(widget)

        PDFFiller.fillFields(in: doc, with: ["agree": "true"])
        XCTAssertEqual(widget.widgetStringValue, "Yes")
    }

    func testFillSetsCheckboxFalse() {
        let doc = PDFDocument()
        let page = PDFPage()
        doc.insert(page, at: 0)

        let widget = PDFAnnotation(bounds: CGRect(x: 0, y: 0, width: 20, height: 20), forType: .widget, withProperties: nil)
        widget.widgetFieldType = .button
        widget.fieldName = "agree"
        widget.widgetStringValue = "Yes"
        page.addAnnotation(widget)

        PDFFiller.fillFields(in: doc, with: ["agree": "no"])
        XCTAssertEqual(widget.widgetStringValue, "Off")
    }

    func testFillIgnoresUnmatchedFields() {
        let doc = PDFDocument()
        let page = PDFPage()
        doc.insert(page, at: 0)

        let widget = PDFAnnotation(bounds: CGRect(x: 0, y: 0, width: 200, height: 30), forType: .widget, withProperties: nil)
        widget.widgetFieldType = .text
        widget.fieldName = "name"
        widget.widgetStringValue = "original"
        page.addAnnotation(widget)

        PDFFiller.fillFields(in: doc, with: ["otherField": "value"])
        XCTAssertEqual(widget.widgetStringValue, "original")
    }

    func testUnfilledFieldsReturnsEmptyOnes() {
        let doc = PDFDocument()
        let page = PDFPage()
        doc.insert(page, at: 0)

        let filled = PDFAnnotation(bounds: CGRect(x: 0, y: 0, width: 200, height: 30), forType: .widget, withProperties: nil)
        filled.widgetFieldType = .text
        filled.fieldName = "name"
        filled.widgetStringValue = "Josh"
        page.addAnnotation(filled)

        let empty = PDFAnnotation(bounds: CGRect(x: 0, y: 40, width: 200, height: 30), forType: .widget, withProperties: nil)
        empty.widgetFieldType = .text
        empty.fieldName = "email"
        empty.widgetStringValue = ""
        page.addAnnotation(empty)

        let unfilled = PDFFiller.unfilledFields(in: doc)
        XCTAssertEqual(unfilled.count, 1)
        XCTAssertEqual(unfilled.first?.name, "email")
    }

    func testFillChoiceWidget() {
        let doc = PDFDocument()
        let page = PDFPage()
        doc.insert(page, at: 0)

        let widget = PDFAnnotation(bounds: CGRect(x: 0, y: 0, width: 200, height: 30), forType: .widget, withProperties: nil)
        widget.widgetFieldType = .choice
        widget.fieldName = "province"
        widget.widgetStringValue = ""
        widget.choices = ["BC", "AB", "ON"]
        page.addAnnotation(widget)

        PDFFiller.fillFields(in: doc, with: ["province": "BC"])
        XCTAssertEqual(widget.widgetStringValue, "BC")
    }
}
