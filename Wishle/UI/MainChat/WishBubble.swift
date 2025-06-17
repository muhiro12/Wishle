import SwiftUI

/// Bubble view presenting a persisted ``Wish``.
struct WishBubble: View {
    let wish: Wish
    let onComplete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(wish.title)
                    .font(.body)
                if let dueDate = wish.dueDate {
                    Text(dueDate, style: .date)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.secondary.opacity(0.2)))
                }
            }
            Spacer()
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.primary.opacity(0.05)))
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .none, action: onComplete) {
                Label("Complete", systemImage: "checkmark")
            }
            .tint(.green)
            .accessibilityLabel("Complete wish")
        }
    }
}

#Preview {
    WishBubble(wish: .init(title: "Sample Wish")) {}
        .padding()
}
