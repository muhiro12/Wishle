import SwiftData
import SwiftUI

struct WishSuggestionView: View {
    @Environment(\.modelContext) private var context

    @State private var suggestedWish: Wish?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var isErrorAlertPresented: Bool = false
    @State private var isPresentingAddSheet: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let wish = suggestedWish {
                    VStack(spacing: 8) {
                        Text(wish.title)
                            .multilineTextAlignment(.center)
                            .padding()
                        if let notes = wish.notes {
                            Text(notes)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding([.horizontal, .bottom])
                        }
                        Button("Add Wish") {
                            isPresentingAddSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isLoading)
                    }
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
            .sheet(isPresented: $isPresentingAddSheet) {
                if let wish = suggestedWish {
                    AddWishView(title: wish.title, notes: wish.notes ?? "", priority: wish.priority)
                }
            }
        }
    }

    private func fetchRandom() {
        isLoading = true
        Task {
            do {
                let wish = try FetchRandomWishIntent.perform(context)
                suggestedWish = wish
            } catch {
                errorMessage = error.localizedDescription
                isErrorAlertPresented = true
                suggestedWish = nil
            }
            isLoading = false
        }
    }

    private func suggestFromRandom() {
        isLoading = true
        Task {
            do {
                let wish = try await SuggestWishFromRandomIntent.perform(context)
                suggestedWish = wish
            } catch {
                errorMessage = error.localizedDescription
                isErrorAlertPresented = true
                suggestedWish = nil
            }
            isLoading = false
        }
    }

    private func suggestFromRecent() {
        isLoading = true
        Task {
            do {
                let wish = try await SuggestWishFromRecentIntent.perform(context)
                suggestedWish = wish
            } catch {
                errorMessage = error.localizedDescription
                isErrorAlertPresented = true
                suggestedWish = nil
            }
            isLoading = false
        }
    }
}

#Preview {
    WishSuggestionView()
        .modelContainer(for: WishModel.self, inMemory: true)
}
