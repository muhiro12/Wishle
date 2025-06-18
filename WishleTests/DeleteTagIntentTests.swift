import SwiftData
import Testing
@testable import Wishle

struct DeleteTagIntentTests {
    private func makeContext() throws -> ModelContext {
        let schema = Schema([TagModel.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return container.mainContext
    }

    @MainActor
    @Test func testDeleteTag() async throws {
        let context = try makeContext()
        let model = TagModel.create(from: .make(name: "Home"), context: context)
        try context.save()
        var intent = DeleteTagIntent()
        intent.id = model.id
        intent.modelContext = context
        _ = try await intent.perform()
        let tags = try context.fetch(FetchDescriptor<TagModel>())
        #expect(tags.isEmpty)
    }

    @MainActor
    @Test func testDeleteInvalidId() async throws {
        let context = try makeContext()
        var intent = DeleteTagIntent()
        intent.id = "invalid"
        intent.modelContext = context
        _ = try await intent.perform()
        let tags = try context.fetch(FetchDescriptor<TagModel>())
        #expect(tags.isEmpty)
    }
}
