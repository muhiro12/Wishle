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
            ScrollView {
                VStack(spacing: 32) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .frame(maxWidth: .infinity)
                    } else if let wish = suggestedWish {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(wish.title)
                                .font(.title2.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if let notes = wish.notes {
                                Text(notes)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Button {
                                isPresentingAddSheet = true
                            } label: {
                                Label("Add to Wishes", systemImage: "plus")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isLoading)
                        }
                        .padding()
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 4)
                        .padding(.horizontal)
                    } else {
                        Text("Tap a button below to get a suggestion.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal)
                    }

                    VStack(spacing: 16) {
                        Button {
                            fetchRandom()
                        } label: {
                            Label("Fetch Random Wish", systemImage: "dice")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(isLoading)

                        Button {
                            suggestFromRandom()
                        } label: {
                            Label("Suggest From Random", systemImage: "sparkles")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(isLoading)

                        Button {
                            suggestFromRecent()
                        } label: {
                            Label("Suggest From Recent", systemImage: "clock")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(isLoading)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Suggestions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        suggestFromRandom()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
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
