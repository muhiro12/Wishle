import AppIntents
import SwiftData

@AppIntent
struct UpdateWishIntent {
    static var title: LocalizedStringResource = "Update Wish"

    @Environment(\.modelContext) private var modelContext

    @Parameter(title: "ID")
    var id: String

    @Parameter(title: "Title")
    var title: String?

    @Parameter(title: "Notes")
    var notes: String?

    @Parameter(title: "Priority")
    var priority: Int?

    static var parameterSummary: some ParameterSummary {
        Summary("Update wish \(\.$id)") {
            \.$title
            \.$notes
            \.$priority
        }
    }

    func perform() async throws -> some IntentResult {
        let descriptor = FetchDescriptor<WishModel>(predicate: #Predicate { $0.id == id })
        guard let model = try modelContext.fetch(descriptor).first else {
            return .result()
        }
        if let title {
            guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return .result()
            }
            model.title = title
        }
        if let notes { model.notes = notes }
        if let priority { model.priority = priority }
        try modelContext.save()
        return .result(value: model.asWish())
    }
}
