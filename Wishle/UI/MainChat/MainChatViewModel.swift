internal import Combine
import Foundation
import SwiftUI

/// Chat bubble types shown in ``MainChatView``.
enum ChatBubble: Identifiable, Hashable {
    case wish(Wish)
    case suggestion(WishSuggestion)

    var id: UUID {
        switch self {
        case let .wish(wish):
            return wish.id
        case let .suggestion(suggestion):
            return suggestion.id
        }
    }
}

/// A suggestion returned from ``AISuggestionService``.
struct WishSuggestion: Identifiable, Hashable {
    var id: UUID = .init()
    var title: String
    var notes: String?
}

/// View model driving ``MainChatView``.
@MainActor final class MainChatViewModel: ObservableObject {
    @Published var bubbles: [ChatBubble] = []

    private let wishService: WishServiceProtocol
    private let suggestionService: AISuggestionServiceProtocol

    init(wishService: WishServiceProtocol,
         suggestionService: AISuggestionServiceProtocol) {
        self.wishService = wishService
        self.suggestionService = suggestionService
    }

    /// Loads wishes and suggestions concurrently.
    func load() async {
        async let wishesTask = fetchWishes()
        async let suggestionsTask = fetchSuggestions()
        let wishes = await wishesTask
        let suggestions = await suggestionsTask
        bubbles = wishes.map(ChatBubble.wish) + suggestions.map(ChatBubble.suggestion)
    }

    /// Adds a new wish from the provided title.
    func addWish(title: String) async {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let wish = try? await wishService.addWish(title: trimmed, notes: nil, dueDate: nil, priority: 0) else { return }
        bubbles.append(.wish(wish))
    }

    /// Marks the given wish as completed.
    func completeWish(_ wish: Wish) async {
        wish.isCompleted = true
        try? await wishService.updateWish(wish)
    }

    /// Converts a suggestion to a persisted wish.
    func acceptSuggestion(_ suggestion: WishSuggestion) async {
        guard let index = bubbles.firstIndex(where: { $0.id == suggestion.id }) else { return }
        guard let wish = try? await wishService.addWish(title: suggestion.title, notes: suggestion.notes, dueDate: nil, priority: 0) else { return }
        bubbles[index] = .wish(wish)
    }

    /// Refreshes AI suggestions.
    func refreshSuggestions() async {
        let suggestions = await fetchSuggestions()
        bubbles.removeAll { bubble in
            if case .suggestion = bubble { return true }return false
        }
        bubbles.append(contentsOf: suggestions.map(ChatBubble.suggestion))
    }

    private func fetchWishes() -> [Wish] {
        (try? wishService.fetchWishes().sorted { $0.createdAt < $1.createdAt }) ?? []
    }

    private func fetchSuggestions() async -> [WishSuggestion] {
        guard let wishes = try? await suggestionService.suggestTasks(for: .init(text: "")) else { return [] }
        return wishes.map { WishSuggestion(title: $0.title, notes: $0.notes) }
    }
}
