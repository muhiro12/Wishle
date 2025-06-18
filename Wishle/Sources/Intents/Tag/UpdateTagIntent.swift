import AppIntents
import SwiftData
import SwiftUtilities

struct UpdateTagIntent: AppIntent, IntentPerformer {
    static var title: LocalizedStringResource = "Update Tag"

    @Environment(\.modelContext) private var modelContext

    @Parameter(title: "ID")
    var id: String

    @Parameter(title: "Name")
    var name: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Update tag \(\.$id)") {
            \.$name
        }
    }

    typealias Input = (context: ModelContext, id: String, name: String?)
    typealias Output = Tag?

    static func perform(_ input: Input) throws -> Output {
        let (context, id, name) = input
        let descriptor = FetchDescriptor<TagModel>(predicate: #Predicate { $0.id == id })
        guard let model = try context.fetch(descriptor).first else { return nil }
        if let name {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            model.name = trimmed
        }
        try context.save()
        return model.asTag()
    }

    func perform() async throws -> some IntentResult {
        if let tag = try await Self.perform((context: modelContext, id: id, name: name)) {
            return .result(value: tag)
        }
        return .result()
    }
}
