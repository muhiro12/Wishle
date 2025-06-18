import AppIntents
import SwiftData
import SwiftUtilities

struct AddTagIntent: AppIntent, IntentPerformer {
    static var title: LocalizedStringResource = "Add Tag"

    @Environment(\.modelContext) private var modelContext

    @Parameter(title: "Name")
    var name: String

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$name)")
    }

    typealias Input = (context: ModelContext, name: String)
    typealias Output = Tag?

    static func perform(_ input: Input) throws -> Output {
        let (context, name) = input
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let tag = Tag.make(name: trimmed)
        TagModel.create(from: tag, context: context)
        try context.save()
        return tag
    }

    func perform() async throws -> some IntentResult {
        if let tag = try await Self.perform((context: modelContext, name: name)) {
            return .result(value: tag)
        }
        return .result()
    }
}
