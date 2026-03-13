import SwiftUI

struct FieldRow: View {
    @Binding var field: FormField

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(field.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("p\(field.page + 1)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)

                Text(field.displayType)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(typeColor.opacity(0.15))
                    .foregroundStyle(typeColor)
                    .clipShape(Capsule())
            }

            fieldInput
        }
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(.quaternary, lineWidth: 0.5)
        )
    }

    @ViewBuilder
    private var fieldInput: some View {
        switch field.type {
        case .checkbox:
            Toggle(isOn: Binding(
                get: { field.currentValue == "true" },
                set: { field.currentValue = $0 ? "true" : "false" }
            )) {
                EmptyView()
            }
            .toggleStyle(.checkbox)

        case .dropdown:
            if let options = field.options, !options.isEmpty {
                Picker("", selection: $field.currentValue) {
                    Text("-- Select --").tag("")
                    ForEach(options, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .labelsHidden()
            } else {
                TextField("Enter value", text: $field.currentValue)
                    .textFieldStyle(.roundedBorder)
            }

        case .radio:
            if let options = field.options, !options.isEmpty {
                ForEach(options, id: \.self) { option in
                    HStack {
                        Image(systemName: field.currentValue == option ? "circle.inset.filled" : "circle")
                            .foregroundStyle(.blue)
                            .onTapGesture { field.currentValue = option }
                        Text(option).font(.body)
                    }
                }
            } else {
                TextField("Enter value", text: $field.currentValue)
                    .textFieldStyle(.roundedBorder)
            }

        case .text, .unknown:
            TextField("Enter value", text: $field.currentValue)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var typeColor: Color {
        switch field.type {
        case .text: return .blue
        case .checkbox: return .green
        case .radio: return .orange
        case .dropdown: return .purple
        case .unknown: return .gray
        }
    }
}
