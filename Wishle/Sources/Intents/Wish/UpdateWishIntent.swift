import AppIntents
import SwiftData
import SwiftUtilities

struct UpdateWishIntent: AppIntent, IntentPerformer {
    static var title: LocalizedStringResource = "Update Wish"

    @Parameter(title: "ID")
    var id: String

    @Parameter(title: "Title")
    var title: String?

    @Parameter(title: "Notes")
    var notes: String?

    @Parameter(title: "Priority")
    var priority: Int?

    @Dependency private var modelContainer: ModelContainer

    static var parameterSummary: some ParameterSummary {
        Summary("Update wish \(\.$id)") {
            \.$title
            \.$notes
            \.$priority
        }
    }

    typealias Input = (context: ModelContext, id: String, title: String?, notes: String?, priority: Int?)
    typealias Output = Wish?

    static func perform(_ input: Input) throws -> Output {
        let (context, id, title, notes, priority) = input
        let descriptor = FetchDescriptor<WishModel>(predicate: #Predicate { $0.id == id })
        guard let model = try context.fetch(descriptor).first else { return nil }
        if let title {
            let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            model.title = trimmed
        }
        if let notes { model.notes = notes }
        if let priority { model.priority = priority }
        try context.save()
        return model.asWish()
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        if let wish = try await Self.perform((context: modelContainer.mainContext, id: id, title: title, notes: notes, priority: priority)) {
            return .result(value: wish)
        }
        return .result()
    }
}
