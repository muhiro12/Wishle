import AppIntents
import SwiftData
import SwiftUtilities

@AppIntent
struct DeleteTagIntent: AppIntent, IntentPerformer {
    static var title: LocalizedStringResource = "Delete Tag"

    @Environment(\.modelContext) private var modelContext

    @Parameter(title: "ID")
    var id: String

    static var parameterSummary: some ParameterSummary {
        Summary("Delete tag \(\.$id)")
    }

    typealias Input = (context: ModelContext, id: String)
    typealias Output = Void

    static func perform(_ input: Input) async throws -> Output {
        let (context, id) = input
        let descriptor = FetchDescriptor<TagModel>(predicate: #Predicate { $0.id == id })
        guard let model = try context.fetch(descriptor).first else { return }
        context.delete(model)
        try context.save()
    }

    func perform() async throws -> some IntentResult {
        try await Self.perform((context: modelContext, id: id))
        return .result()
    }
}
