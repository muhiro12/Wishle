import Testing
@testable import Wishle

struct AISuggestionServiceTests {

    @Test
    func testSuggestTasks() async throws {
        let service = AISuggestionService(randomProvider: SeededRandomProvider(seed: 42))
        let tasks = try await service.suggestTasks(for: .init(text: "Plan a weekend getaway"))
        #expect(!tasks.isEmpty)
    }
}
