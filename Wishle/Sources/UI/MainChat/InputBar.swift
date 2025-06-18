import SwiftUI

/// Input bar used at the bottom of ``MainChatView``.
struct InputBar: View {
    @State private var text = ""
    let onSend: (String) -> Void

    var body: some View {
        HStack {
            TextField("New wish", text: $text)
            Button("Send") {
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                onSend(trimmed)
                text = ""
            }
            .accessibilityLabel("Send wish")
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    InputBar { _ in }
}
