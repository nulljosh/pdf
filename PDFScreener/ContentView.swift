import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        HSplitView {
            fieldPanel
                .frame(minWidth: 350, idealWidth: 400)

            pdfPanel
                .frame(minWidth: 400)
        }
        .frame(minWidth: 900, minHeight: 600)
        .fileImporter(
            isPresented: $appState.showFileImporter,
            allowedContentTypes: [UTType.pdf],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                appState.loadPDF(from: url)
            }
        }
        .onDrop(of: [UTType.fileURL], isTargeted: nil) { providers in
            handleDrop(providers)
        }
        .toolbar {
            ToolbarItemGroup {
                Button("Open") {
                    appState.showFileImporter = true
                }

                if appState.pdfDocument != nil {
                    Button("Save Filled") {
                        appState.fillAndSave()
                    }
                    .disabled(appState.isProcessing)

                    Button("Export JSON") {
                        exportJSON()
                    }
                }
            }
        }
    }

    private var fieldPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            statusBar

            if appState.fields.isEmpty {
                emptyState
            } else {
                fieldList
            }
        }
        .background(.ultraThinMaterial)
    }

    private var statusBar: some View {
        HStack {
            Text(appState.statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            if !appState.fields.isEmpty {
                let filled = appState.fields.filter { !$0.isEmpty }.count
                Text("\(filled)/\(appState.fields.count) filled")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.regularMaterial)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("Drop a PDF here")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("or press Cmd+O to open")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private var fieldList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach($appState.fields) { $field in
                    FieldRow(field: $field)
                }
            }
            .padding(12)
        }
    }

    private var pdfPanel: some View {
        Group {
            if let doc = appState.pdfDocument {
                PDFViewWrapper(document: doc)
            } else {
                Color(nsColor: .underPageBackgroundColor)
                    .overlay {
                        Text("PDF preview")
                            .foregroundStyle(.quaternary)
                    }
            }
        }
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
            Task { @MainActor in
                appState.loadPDF(from: url)
            }
        }
        return true
    }

    private func exportJSON() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.json]
        panel.nameFieldStringValue = (appState.pdfURL?.deletingPathExtension().lastPathComponent ?? "answers") + ".answers.json"
        if panel.runModal() == .OK, let url = panel.url {
            let json = appState.exportAnswersJSON()
            try? json.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}
