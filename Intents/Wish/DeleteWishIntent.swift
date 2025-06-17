import AppIntents
import SwiftData

@AppIntent
struct DeleteWishIntent {
    static var title: LocalizedStringResource = "Delete Wish"

    @Environment(\.modelContext) private var modelContext

    @Parameter(title: "ID")
    var id: String

    static var parameterSummary: some ParameterSummary {
        Summary("Delete wish \(\.$id)")
    }

    func perform() async throws -> some IntentResult {
        let descriptor = FetchDescriptor<WishModel>(predicate: #Predicate { $0.id == id })
        guard let model = try modelContext.fetch(descriptor).first else {
            return .result()
        }
        modelContext.delete(model)
        try modelContext.save()
        return .result()
    }
}
