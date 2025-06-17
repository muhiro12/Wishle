import Testing
@testable import Wishle

struct MainChatViewModelTests {
    @Test
    func testLoadSuccess() async {
        let wish = Wish(title: "A")
        let wishService = MockWishService(wishes: [wish])
        let suggestion = Wish(title: "B")
        let suggestionService = MockSuggestionService(result: .success([suggestion]))
        let viewModel = MainChatViewModel(wishService: wishService, suggestionService: suggestionService)
        await viewModel.load()
        #expect(viewModel.bubbles.count == 2)
    }

    @Test
    func testLoadFailure() async {
        let wishService = MockWishService(error: TestError())
        let suggestionService = MockSuggestionService(result: .failure(TestError()))
        let viewModel = MainChatViewModel(wishService: wishService, suggestionService: suggestionService)
        await viewModel.load()
        #expect(viewModel.bubbles.isEmpty)
    }
}

private struct TestError: Error {}

private final class MockWishService: WishServiceProtocol {
    var result: Result<[Wish], Error>

    init(wishes: [Wish]) { result = .success(wishes) }
    init(error: Error) { result = .failure(error) }

    func fetchWishes() throws -> [Wish] { try result.get() }
    func addWish(title: String, notes: String?, dueDate: Date?, priority: Int) throws -> Wish { .init(title: title) }
    func wish(id: UUID) -> Wish? { nil }
    func updateWish(_ wish: Wish) throws {}
    func deleteWish(_ wish: Wish) throws {}
    func nextUpWish() -> Wish? { nil }
    var context: ModelContext { fatalError() }
}

private struct MockSuggestionService: AISuggestionServiceProtocol {
    var result: Result<[Wish], Error>
    func suggestTasks(for context: SuggestionContext) async throws -> [Wish] {
        try result.get()
    }
}
