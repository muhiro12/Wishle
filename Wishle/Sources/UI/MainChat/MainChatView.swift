import SwiftData
import SwiftUI
import SwiftUtilities

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

struct WishSuggestion: Identifiable, Hashable {
    var id: UUID = .init()
    var title: String
    var notes: String?
}

/// Root chat-style timeline allowing users to manage wishes.
struct MainChatView: View {
    @Environment(\.modelContext) private var modelContext
    @BridgeQuery(.init(sort: \WishModel.createdAt)) private var wishes: [Wish]
    @State private var suggestions: [WishSuggestion] = []
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var isOnboardingPresented = false
    @State private var isPaywallPresented = false
    @State private var subscriptionManager = SubscriptionManager.shared

    private var bubbles: [ChatBubble] {
        wishes.map(ChatBubble.wish) + suggestions.map(ChatBubble.suggestion)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(bubbles) { bubble in
                            switch bubble {
                            case let .wish(wish):
                                WishBubble(wish: wish) {
                                    Task { await completeWish(wish) }
                                }
                                .id(bubble.id)
                            case let .suggestion(suggestion):
                                SuggestionBubble(suggestion: suggestion) {
                                    Task { await acceptSuggestion(suggestion) }
                                }
                                .id(bubble.id)
                            }
                        }
                    }
                    .padding()
                }
                .refreshable { await refreshSuggestions() }
                .onChange(of: bubbles.count) { _, _ in
                    if let last = bubbles.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            InputBar { title in
                Task { await addWish(title: title) }
            }
        }
        .sheet(isPresented: $isPaywallPresented) {
            PaywallView()
        }
        .fullScreenCover(isPresented: $isOnboardingPresented) {
            OnboardingFlow()
        }
        .task {
            await load()
            isOnboardingPresented = !hasSeenOnboarding
            await subscriptionManager.load()
            isPaywallPresented = !subscriptionManager.isSubscribed
        }
        .onChange(of: subscriptionManager.isSubscribed) { _, newValue in
            isPaywallPresented = !newValue
        }
    }

    private func load() async {
        suggestions = await fetchSuggestions()
    }

    private func addWish(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let wish = Wish(title: trimmed)
        modelContext.insert(wish)
        try? modelContext.save()
    }

    private func completeWish(_ wish: Wish) {
        wish.isCompleted = true
        try? modelContext.save()
    }

    private func acceptSuggestion(_ suggestion: WishSuggestion) {
        guard let index = suggestions.firstIndex(where: { $0.id == suggestion.id }) else {
            return
        }
        let wish = Wish(title: suggestion.title, notes: suggestion.notes)
        modelContext.insert(wish)
        try? modelContext.save()
        suggestions.remove(at: index)
    }

    private func refreshSuggestions() async {
        suggestions = await fetchSuggestions()
    }

    private func fetchSuggestions() async -> [WishSuggestion] {
        guard let wishes = try? await AISuggestionService.shared
                .suggestTasks(for: .init(text: "")) else {
            return []
        }
        return wishes.map { WishSuggestion(title: $0.title, notes: $0.notes) }
    }
}

#Preview {
    MainChatView()
}
