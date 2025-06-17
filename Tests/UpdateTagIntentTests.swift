import Testing
import SwiftData
@testable import Wishle

struct UpdateTagIntentTests {
    private func makeContext() throws -> ModelContext {
        let schema = Schema([TagModel.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return container.mainContext
    }

    @MainActor
    @Test func testUpdateTag() async throws {
        let context = try makeContext()
        let model = TagModel.create(from: .make(name: "Home"), context: context)
        try context.save()
        var intent = UpdateTagIntent()
        intent.id = model.id
        intent.name = "Work"
        intent.modelContext = context
        _ = try await intent.perform()
        let updated = try context.fetch(FetchDescriptor<TagModel>()).first!
        #expect(updated.name == "Work")
    }

    @MainActor
    @Test func testUpdateInvalidId() async throws {
        let context = try makeContext()
        var intent = UpdateTagIntent()
        intent.id = "invalid"
        intent.name = "Work"
        intent.modelContext = context
        _ = try await intent.perform()
        let tags = try context.fetch(FetchDescriptor<TagModel>())
        #expect(tags.isEmpty)
    }

    @MainActor
    @Test func testUpdateEmptyName() async throws {
        let context = try makeContext()
        let model = TagModel.create(from: .make(name: "Home"), context: context)
        try context.save()
        var intent = UpdateTagIntent()
        intent.id = model.id
        intent.name = ""
        intent.modelContext = context
        _ = try await intent.perform()
        let loaded = try context.fetch(FetchDescriptor<TagModel>()).first!
        #expect(loaded.name == "Home")
    }
}
