import AppIntents
import FoundationModels
import SwiftUtilities

struct SummarizeChatIntent: AppIntent, IntentPerformer {
    typealias Input = Void
    typealias Output = Wish

    nonisolated static let title: LocalizedStringResource = "Summarize Chat"

    static func perform(_: Input) async throws -> Output {
        let language = Locale.current.language.languageCode?.identifier ?? Locale.current.identifier
        let prompt = "Respond in the user's device language: \(language). Summarize our conversation as a wish."
        let result = try await ChatSession.session.respond(
            to: prompt,
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
