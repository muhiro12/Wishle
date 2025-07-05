import AppIntents
import FoundationModels
import SwiftUtilities

struct SummarizeChatIntent: AppIntent, IntentPerformer {
    typealias Input = Void
    typealias Output = Wish

    nonisolated static let title: LocalizedStringResource = "Summarize Chat"

    static func perform(_: Input) async throws -> Output {
        let result = try await ChatSession.session.respond(
            to: "Summarize our conversation as a wish.",
            generating: WishDraft.self
        )
        return .init(
            title: result.content.title,
            notes: result.content.notes,
            priority: result.content.priority
        )
    }

    func perform() async throws -> some ReturnsValue<String> {
        let wish = try await Self.perform(())
        return .result(value: wish.title)
    }
}
