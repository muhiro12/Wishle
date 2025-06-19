import Testing
@testable import Wishle

struct AISuggestionServiceTests {
    @Test
    func testSuggestWishes() async throws {
        let service = AISuggestionService(randomProvider: SeededRandomProvider(seed: 42))
        let wishes = try await service.suggestWishes(for: .init(text: "Plan a weekend getaway"))
        #expect(!wishes.isEmpty)
    }
}
