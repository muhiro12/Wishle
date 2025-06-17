import AppIntents
import SwiftData

@AppIntent
struct DeleteTagIntent {
    static var title: LocalizedStringResource = "Delete Tag"

    @Environment(\.modelContext) private var modelContext

    @Parameter(title: "ID")
    var id: String

    static var parameterSummary: some ParameterSummary {
        Summary("Delete tag \(\.$id)")
    }

    func perform() async throws -> some IntentResult {
        let descriptor = FetchDescriptor<TagModel>(predicate: #Predicate { $0.id == id })
        guard let model = try modelContext.fetch(descriptor).first else {
            return .result()
        }
        modelContext.delete(model)
        try modelContext.save()
        return .result()
    }
}
