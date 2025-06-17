import Testing
import SwiftData
@testable import Wishle

struct UpdateWishIntentTests {
    private func makeContext() throws -> ModelContext {
        let schema = Schema([WishModel.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return container.mainContext
    }

    @MainActor
    @Test func testUpdateWish() async throws {
        let context = try makeContext()
        let wish = Wish.make(title: "Old")
        let model = WishModel.create(from: wish, context: context)
        try context.save()
        var intent = UpdateWishIntent()
        intent.id = model.id
        intent.title = "New"
        intent.priority = 2
        intent.modelContext = context
        _ = try await intent.perform()
        let updated = try context.fetch(FetchDescriptor<WishModel>()).first!
        #expect(updated.title == "New")
        #expect(updated.priority == 2)
    }

    @MainActor
    @Test func testUpdateInvalidId() async throws {
        let context = try makeContext()
        var intent = UpdateWishIntent()
        intent.id = "invalid"
        intent.title = "New"
        intent.modelContext = context
        _ = try await intent.perform()
        let wishes = try context.fetch(FetchDescriptor<WishModel>())
        #expect(wishes.isEmpty)
    }

    @MainActor
    @Test func testUpdateEmptyTitle() async throws {
        let context = try makeContext()
        let model = WishModel.create(from: Wish.make(title: "Old"), context: context)
        try context.save()
        var intent = UpdateWishIntent()
        intent.id = model.id
        intent.title = ""
        intent.modelContext = context
        _ = try await intent.perform()
        let loaded = try context.fetch(FetchDescriptor<WishModel>()).first!
        #expect(loaded.title == "Old")
    }
}
