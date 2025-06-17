import AppIntents
import SwiftData

@AppIntent
struct AddTagIntent {
    static var title: LocalizedStringResource = "Add Tag"

    @Environment(\.modelContext) private var modelContext

    @Parameter(title: "Name")
    var name: String

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$name)")
    }

    func perform() async throws -> some IntentResult {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .result()
        }
        let tag = Tag.make(name: name)
        TagModel.create(from: tag, context: modelContext)
        try modelContext.save()
        return .result(value: tag)
    }
}
