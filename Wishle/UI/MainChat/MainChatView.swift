import SwiftUI

/// Root chat-style timeline allowing users to manage wishes.
struct MainChatView: View {
    @StateObject private var viewModel = MainChatViewModel(wishService: WishService.shared, suggestionService: AISuggestionService.shared)
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var isOnboardingPresented = false
    @State private var isPaywallPresented = false
    @State private var subscriptionManager = SubscriptionManager.shared

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.bubbles) { bubble in
                            switch bubble {
                            case let .wish(wish):
                                WishBubble(wish: wish) {
                                    Task { await viewModel.completeWish(wish) }
                                }
                                .id(bubble.id)
                            case let .suggestion(suggestion):
                                SuggestionBubble(suggestion: suggestion) {
                                    Task { await viewModel.acceptSuggestion(suggestion) }
                                }
                                .id(bubble.id)
                            }
                        }
                    }
                    .padding()
                }
                .refreshable { await viewModel.refreshSuggestions() }
                .onChange(of: viewModel.bubbles.count) { _, _ in
                    if let last = viewModel.bubbles.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            InputBar { title in
                Task { await viewModel.addWish(title: title) }
            }
        }
        .sheet(isPresented: $isPaywallPresented) {
            PaywallView()
        }
        .fullScreenCover(isPresented: $isOnboardingPresented) {
            OnboardingFlow()
        }
        .task {
            await viewModel.load()
            isOnboardingPresented = !hasSeenOnboarding
            await subscriptionManager.load()
            isPaywallPresented = !subscriptionManager.isSubscribed
        }
        .onChange(of: subscriptionManager.isSubscribed) { _, newValue in
            isPaywallPresented = !newValue
        }
    }
}

#Preview {
    MainChatView()
}
