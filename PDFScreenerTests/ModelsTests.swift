import XCTest
@testable import PDF_Screener

final class ModelsTests: XCTestCase {
    func testFieldTypeRawValues() {
        XCTAssertEqual(FieldType.text.rawValue, "text")
        XCTAssertEqual(FieldType.checkbox.rawValue, "checkbox")
        XCTAssertEqual(FieldType.radio.rawValue, "radio")
        XCTAssertEqual(FieldType.dropdown.rawValue, "dropdown")
        XCTAssertEqual(FieldType.unknown.rawValue, "unknown")
    }

    func testFormFieldInit() {
        let field = FormField(
            name: "firstName",
            type: .text,
            currentValue: "Josh",
            page: 0,
            options: nil,
            annotation: nil
        )
        XCTAssertEqual(field.name, "firstName")
        XCTAssertEqual(field.type, .text)
        XCTAssertEqual(field.currentValue, "Josh")
        XCTAssertEqual(field.page, 0)
        XCTAssertNil(field.options)
        XCTAssertNil(field.annotation)
    }

    func testIsEmptyWithBlankValue() {
        let field = FormField(
            name: "test",
            type: .text,
            currentValue: "",
            page: 0,
            options: nil,
            annotation: nil
        )
        XCTAssertTrue(field.isEmpty)
    }

    func testIsEmptyWithWhitespace() {
        let field = FormField(
            name: "test",
            type: .text,
            currentValue: "   \n  ",
            page: 0,
            options: nil,
            annotation: nil
        )
        XCTAssertTrue(field.isEmpty)
    }

    func testIsEmptyWithValue() {
        let field = FormField(
            name: "test",
            type: .text,
            currentValue: "hello",
            page: 0,
            options: nil,
            annotation: nil
        )
        XCTAssertFalse(field.isEmpty)
    }

    func testDisplayType() {
        XCTAssertEqual(
            FormField(name: "a", type: .text, currentValue: "", page: 0, options: nil, annotation: nil).displayType,
            "Text"
        )
        XCTAssertEqual(
            FormField(name: "a", type: .checkbox, currentValue: "", page: 0, options: nil, annotation: nil).displayType,
            "Checkbox"
        )
        XCTAssertEqual(
            FormField(name: "a", type: .dropdown, currentValue: "", page: 0, options: ["A", "B"], annotation: nil).displayType,
            "Dropdown"
        )
    }

    func testFieldTypeDecodable() throws {
        let json = "\"radio\""
        let data = json.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(FieldType.self, from: data)
        XCTAssertEqual(decoded, .radio)
    }

    func testFieldTypeEncodable() throws {
        let data = try JSONEncoder().encode(FieldType.checkbox)
        let str = String(data: data, encoding: .utf8)!
        XCTAssertEqual(str, "\"checkbox\"")
    }

    func testFormFieldIdentifiable() {
        let a = FormField(name: "x", type: .text, currentValue: "", page: 0, options: nil, annotation: nil)
        let b = FormField(name: "x", type: .text, currentValue: "", page: 0, options: nil, annotation: nil)
        XCTAssertNotEqual(a.id, b.id, "Each FormField should have a unique UUID")
    }
}
