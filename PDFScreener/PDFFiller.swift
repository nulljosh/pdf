import PDFKit

struct PDFFiller {
    static func fillFields(in document: PDFDocument, with answers: [String: String]) {
        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex) else { continue }

            for annotation in page.annotations {
                guard let widget = annotation as? PDFAnnotation,
                      let fieldName = widget.fieldName,
                      let answer = answers[fieldName] else { continue }

                let fieldType = widget.widgetFieldType

                switch fieldType {
                case .button:
                    let boolVal = ["true", "yes", "on", "1"].contains(answer.lowercased())
                    widget.widgetStringValue = boolVal ? "Yes" : "Off"
                case .text, .choice:
                    widget.widgetStringValue = answer
                default:
                    widget.widgetStringValue = answer
                }
            }
        }
    }

    static func unfilledFields(in document: PDFDocument) -> [FormField] {
        let fields = PDFExtractor.extractFields(from: document)
        return fields.filter { $0.isEmpty }
    }
}
