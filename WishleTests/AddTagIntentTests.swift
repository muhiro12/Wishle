import SwiftData
import Testing
@testable import Wishle

struct AddTagIntentTests {
    private func makeContext() throws -> ModelContext {
        let schema = Schema([TagModel.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return container.mainContext
    }

    @MainActor
    @Test func testAddTag() async throws {
        let context = try makeContext()
        var intent = AddTagIntent()
        intent.name = "Home"
        intent.modelContext = context
        _ = try await intent.perform()
        let tags = try context.fetch(FetchDescriptor<TagModel>())
        #expect(tags.count == 1)
        #expect(tags.first?.name == "Home")
    }

    @MainActor
    @Test func testAddTagEmpty() async throws {
        let context = try makeContext()
        var intent = AddTagIntent()
        intent.name = ""
        intent.modelContext = context
        _ = try await intent.perform()
        let tags = try context.fetch(FetchDescriptor<TagModel>())
        #expect(tags.isEmpty)
    }
}
