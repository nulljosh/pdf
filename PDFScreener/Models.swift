import Foundation
import PDFKit

enum FieldType: String, Codable {
    case text
    case checkbox
    case radio
    case dropdown
    case unknown
}

struct FormField: Identifiable {
    let id = UUID()
    let name: String
    let type: FieldType
    var currentValue: String
    let page: Int
    let options: [String]?
    let annotation: PDFAnnotation?

    var isEmpty: Bool {
        currentValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var displayType: String {
        type.rawValue.capitalized
    }
}
