import PDFKit

struct PDFExtractor {
    static func extractFields(from document: PDFDocument) -> [FormField] {
        var fields: [FormField] = []

        for pageIndex in 0..<document.pageCount {
            guard let page = document.page(at: pageIndex) else { continue }

            for annotation in page.annotations {
                guard let widget = annotation as? PDFAnnotation,
                      let fieldName = widget.fieldName,
                      !fieldName.isEmpty else { continue }

                let widgetType = widget.widgetFieldType
                let fieldType = mapWidgetType(widgetType)
                let value = extractValue(from: widget, type: fieldType)
                let options = extractOptions(from: widget, type: fieldType)

                let field = FormField(
                    name: fieldName,
                    type: fieldType,
                    currentValue: value,
                    page: pageIndex,
                    options: options,
                    annotation: widget
                )
                fields.append(field)
            }
        }

        return fields
    }

    private static func mapWidgetType(_ type: PDFAnnotationWidgetSubtype) -> FieldType {
        switch type {
        case .text:
            return .text
        case .button:
            return .checkbox
        case .choice:
            return .dropdown
        default:
            return .unknown
        }
    }

    private static func extractValue(from widget: PDFAnnotation, type: FieldType) -> String {
        switch type {
        case .checkbox:
            let val = widget.widgetStringValue ?? ""
            return (val == "Yes" || val == "On") ? "true" : "false"
        default:
            return widget.widgetStringValue ?? ""
        }
    }

    private static func extractOptions(from widget: PDFAnnotation, type: FieldType) -> [String]? {
        guard type == .dropdown else { return nil }
        return widget.choices
    }
}
