import AppIntents
import SwiftData
import SwiftUtilities

@AppIntent
struct AddWishIntent: AppIntent, IntentPerformer {
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

    typealias Input = (context: ModelContext, title: String, notes: String?, priority: Int)
    typealias Output = Wish?

    static func perform(_ input: Input) async throws -> Output {
        let (context, title, notes, priority) = input
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let wish = Wish.make(title: trimmed, notes: notes, priority: priority)
        WishModel.create(from: wish, context: context)
        try context.save()
        return wish
    }

    func perform() async throws -> some IntentResult {
        if let wish = try await Self.perform((context: modelContext, title: title, notes: notes, priority: priority)) {
            return .result(value: wish)
        }
        return .result()
    }
}
