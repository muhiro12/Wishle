import SwiftData
import SwiftUI

struct WishSuggestionView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var suggestion: String = ""
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if !suggestion.isEmpty {
                    Text(suggestion)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                Button("Fetch Random Wish") {
                    fetchRandom()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)

                Button("Suggest From Random") {
                    suggestFromRandom()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)

                Button("Suggest From Recent") {
                    suggestFromRecent()
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)
                Spacer()
            }
            .navigationTitle("Suggestions")
            .padding()
        }
    }

    private func fetchRandom() {
        isLoading = true
        Task {
            let wish = try? FetchRandomWishIntent.perform(modelContext)
            suggestion = wish?.title ?? ""
            isLoading = false
        }
    }

    private func suggestFromRandom() {
        isLoading = true
        Task {
            let wish = try? await SuggestWishFromRandomIntent.perform(modelContext)
            suggestion = wish?.title ?? ""
            isLoading = false
        }
    }

    private func suggestFromRecent() {
        isLoading = true
        Task {
            let wish = try? await SuggestWishFromRecentIntent.perform(modelContext)
            suggestion = wish?.title ?? ""
            isLoading = false
        }
    }
}

#Preview {
    WishSuggestionView()
        .modelContainer(for: WishModel.self, inMemory: true)
}
