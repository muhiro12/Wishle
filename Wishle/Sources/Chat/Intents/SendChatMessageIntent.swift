import AppIntents
import FoundationModels
import SwiftUtilities

struct SendChatMessageIntent: AppIntent, IntentPerformer {
    typealias Input = String
    typealias Output = String

    @Parameter(title: "Message")
    private var text: String

    nonisolated static let title: LocalizedStringResource = "Send Chat Message"

    static func perform(_ input: Input) async throws -> Output {
        let language = Locale.current.language.languageCode?.identifier ?? Locale.current.identifier
        let prompt = "Respond in the user's device language: \(language). \(input)"
        let reply = try await ChatSession.session.respond(to: prompt)
        return reply.content
    }

    func perform() async throws -> some ReturnsValue<String> {
        .result(value: try await Self.perform(text))
    }
}
