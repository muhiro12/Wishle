import AppIntents
import FoundationModels

struct SendChatMessageIntent: AppIntent, IntentPerformer {
    typealias Input = String
    typealias Output = String

    @Parameter(title: "Message")
    private var text: String

    nonisolated static let title: LocalizedStringResource = "Send Chat Message"

    static func perform(_ input: Input) async throws -> Output {
        let reply = try await ChatSession.session.respond(to: input)
        return reply.content
    }

    func perform() async throws -> some ReturnsValue<String> {
        .result(value: try await Self.perform(text))
    }
}
