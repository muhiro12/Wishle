import SwiftData
import SwiftUI

struct WishSuggestionView: View {
    @Environment(\.modelContext) private var context

    @State private var suggestion: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var isErrorAlertPresented: Bool = false

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
            .alert(
                "Error",
                isPresented: $isErrorAlertPresented
            ) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "An unknown error occurred.")
            }
        }
    }

    private func fetchRandom() {
        isLoading = true
        Task {
            do {
                let wish = try FetchRandomWishIntent.perform(context)
                suggestion = wish.title
            } catch {
                errorMessage = error.localizedDescription
                isErrorAlertPresented = true
                suggestion = ""
            }
            isLoading = false
        }
    }

    private func suggestFromRandom() {
        isLoading = true
        Task {
            do {
                let wish = try await SuggestWishFromRandomIntent.perform(context)
                suggestion = wish.title
            } catch {
                errorMessage = error.localizedDescription
                isErrorAlertPresented = true
                suggestion = ""
            }
            isLoading = false
        }
    }

    private func suggestFromRecent() {
        isLoading = true
        Task {
            do {
                let wish = try await SuggestWishFromRecentIntent.perform(context)
                suggestion = wish.title
            } catch {
                errorMessage = error.localizedDescription
                isErrorAlertPresented = true
                suggestion = ""
            }
            isLoading = false
        }
    }
}

#Preview {
    WishSuggestionView()
        .modelContainer(for: WishModel.self, inMemory: true)
}
