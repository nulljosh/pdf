# PDF Screener

## What This Is
Native macOS SwiftUI app. Extracts PDF form fields, presents editable form UI, writes answers back.

## Architecture
```
pdf/
  project.yml              # xcodegen config
  PDFScreener/
    PDFScreenerApp.swift    # @main entry point
    AppState.swift          # @MainActor ObservableObject, PDF loading/saving
    ContentView.swift       # HSplitView: fields left, PDF preview right
    FieldRow.swift          # Per-field editor (text/checkbox/dropdown/radio)
    PDFViewWrapper.swift    # NSViewRepresentable for PDFView
    PDFExtractor.swift      # AcroForm widget field extraction
    PDFFiller.swift         # Write answers back to PDF annotations
    Models.swift            # FormField, FieldType
    Info.plist
  PDFScreenerTests/
    AppStateTests.swift     # State management + PDF load/save tests
    ExtractorTests.swift    # AcroForm extraction tests
    FillerTests.swift       # PDF annotation writing tests
    ModelsTests.swift       # Data model + FieldType tests
  docs/
    index.html              # GitHub Pages splash (portfolio style)
    style.css               # Design system (Inter, light/dark toggle)
    CNAME                   # pdf.heyitsmejosh.com
  icon.svg
  architecture.svg
```

## Tech Stack
- **SwiftUI** - UI framework, macOS 14+
- **PDFKit** - PDF rendering + AcroForm extraction
- **xcodegen** - Project file generation

## Key Decisions
- No external dependencies. PDFKit handles all PDF operations natively
- Answers stored as JSON sidecar files alongside PDFs
- HSplitView layout: form fields left, PDF preview right
- Field types: text, checkbox, radio, dropdown, unknown
- Apple Liquid Glass materials (.ultraThinMaterial, .regularMaterial) for frosted UI

## Build
```bash
xcodegen generate
xcodebuild -scheme PDFScreener build
```

## Tests
29 XCTests across 4 files.
```bash
xcodebuild -scheme PDFScreenerTests -destination 'platform=macOS,arch=arm64' test
```

## Pages
GitHub Pages at pdf.heyitsmejosh.com (source: docs/ on main).

## Coding Standards
- camelCase, Swift conventions
- @MainActor for all UI state
- NSViewRepresentable for AppKit bridging
