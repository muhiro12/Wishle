import SwiftUI

/// Bubble view presenting an AI-generated ``WishSuggestion``.
struct SuggestionBubble: View {
    let suggestion: WishSuggestion
    let onAdd: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(suggestion.title)
                    .font(.body)
                if let notes = suggestion.notes {
                    Text(notes)
                        .font(.caption)
                }
            }
            Spacer()
            Button("Add", action: onAdd)
                .buttonStyle(.borderedProminent)
                .tint(.white)
                .foregroundStyle(Color("WishlePrimary"))
                .accessibilityLabel("Add suggestion")
        }
        .padding(12)
        .foregroundStyle(.white)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("WishlePrimary"))
        )
    }
}

#Preview {
    SuggestionBubble(suggestion: .init(title: "Try something new")) {}
        .padding()
}
