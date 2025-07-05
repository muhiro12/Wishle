import AppIntents
import FoundationModels
import SwiftUtilities
import Foundation

struct SendChatMessageIntent: AppIntent, IntentPerformer {
    typealias Input = String
    typealias Output = String

    @Parameter(title: "Message")
    private var text: String

    nonisolated static let title: LocalizedStringResource = "Send Chat Message"

    static func perform(_ input: Input) async throws -> Output {
        let prompt = PromptHelper.localized(input)
        let reply = try await ChatSession.session.respond(to: prompt)
        return reply.content
    }

    func perform() async throws -> some ReturnsValue<String> {
        .result(value: try await Self.perform(text))
    }
}
