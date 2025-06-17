import AppIntents
import SwiftData

@AppIntent
struct AddWishIntent {
    static var title: LocalizedStringResource = "Add Wish"

    @Environment(\.modelContext) private var modelContext

    @Parameter(title: "Title")
    var title: String

    @Parameter(title: "Notes")
    var notes: String?

    @Parameter(title: "Priority", default: 0)
    var priority: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$title)") {
            \.$notes
            \.$priority
        }
    }

    func perform() async throws -> some IntentResult {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .result()
        }
        let wish = Wish.make(title: title,
                             notes: notes,
                             priority: priority)
        WishModel.create(from: wish, context: modelContext)
        try modelContext.save()
        return .result(value: wish)
    }
}
