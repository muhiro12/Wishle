import Testing
import SwiftData
@testable import Wishle

struct DeleteWishIntentTests {
    private func makeContext() throws -> ModelContext {
        let schema = Schema([WishModel.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return container.mainContext
    }

    @MainActor
    @Test func testDeleteWish() async throws {
        let context = try makeContext()
        let model = WishModel.create(from: Wish.make(title: "temp"), context: context)
        try context.save()
        var intent = DeleteWishIntent()
        intent.id = model.id
        intent.modelContext = context
        _ = try await intent.perform()
        let wishes = try context.fetch(FetchDescriptor<WishModel>())
        #expect(wishes.isEmpty)
    }

    @MainActor
    @Test func testDeleteInvalidId() async throws {
        let context = try makeContext()
        var intent = DeleteWishIntent()
        intent.id = "invalid"
        intent.modelContext = context
        _ = try await intent.perform()
        let wishes = try context.fetch(FetchDescriptor<WishModel>())
        #expect(wishes.isEmpty)
    }
}
