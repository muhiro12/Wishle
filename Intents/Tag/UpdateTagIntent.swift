import AppIntents
import SwiftData

@AppIntent
struct UpdateTagIntent {
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

    func perform() async throws -> some IntentResult {
        let descriptor = FetchDescriptor<TagModel>(predicate: #Predicate { $0.id == id })
        guard let model = try modelContext.fetch(descriptor).first else {
            return .result()
        }
        if let name {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return .result() }
            model.name = trimmed
        }
        try modelContext.save()
        return .result(value: model.asTag())
    }
}
