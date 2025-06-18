import AppIntents
import SwiftData
import SwiftUtilities

struct DeleteWishIntent: AppIntent, IntentPerformer {
    static var title: LocalizedStringResource = "Delete Wish"

    @Environment(\.modelContext) private var modelContext

    @Parameter(title: "ID")
    var id: String

    static var parameterSummary: some ParameterSummary {
        Summary("Delete wish \(\.$id)")
    }

    typealias Input = (context: ModelContext, id: String)
    typealias Output = Void

    static func perform(_ input: Input) throws -> Output {
        let (context, id) = input
        let descriptor = FetchDescriptor<WishModel>(predicate: #Predicate { $0.id == id })
        guard let model = try context.fetch(descriptor).first else { return }
        context.delete(model)
        try context.save()
    }

    func perform() async throws -> some IntentResult {
        try await Self.perform((context: modelContext, id: id))
        return .result()
    }
}
