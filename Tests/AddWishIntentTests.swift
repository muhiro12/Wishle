import Testing
import SwiftData
@testable import Wishle

struct AddWishIntentTests {
    private func makeContext() throws -> ModelContext {
        let schema = Schema([WishModel.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return container.mainContext
    }

    @MainActor
    @Test func testAddWish() async throws {
        let context = try makeContext()
        var intent = AddWishIntent()
        intent.title = "Hello"
        intent.notes = "note"
        intent.priority = 1
        intent.modelContext = context
        _ = try await intent.perform()
        let wishes = try context.fetch(FetchDescriptor<WishModel>())
        #expect(wishes.count == 1)
        #expect(wishes.first?.title == "Hello")
    }

    @MainActor
    @Test func testAddWishEmptyTitle() async throws {
        let context = try makeContext()
        var intent = AddWishIntent()
        intent.title = ""
        intent.modelContext = context
        _ = try await intent.perform()
        let wishes = try context.fetch(FetchDescriptor<WishModel>())
        #expect(wishes.isEmpty)
    }
}
