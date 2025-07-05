import AppIntents
import FoundationModels
import SwiftUtilities

@Generable
private struct WishSuggestion: Decodable {
    var title: String
    var notes: String?
}

struct SuggestWishIntent: AppIntent, IntentPerformer {
    typealias Input = String
    typealias Output = Wish

    @Parameter(title: "Context")
    private var text: String

    nonisolated static let title: LocalizedStringResource = "Suggest Wish"

    private static var promptTemplate: String {
        if let url = Bundle.main.url(
            forResource: "suggestion_template",
            withExtension: "txt",
            subdirectory: "Prompts"
        ),
        let template = try? String(contentsOf: url, encoding: .utf8) {
            return template
        }
        return ""
    }

    static func perform(_ input: Input) async throws -> Wish {
        let prompt = promptTemplate.replacingOccurrences(of: "{{context}}", with: input)
        let session = LanguageModelSession()
        let response = try await session.respond(
            to: prompt,
            generating: [WishSuggestion].self
        )
        guard let suggestion = response.content.first else {
            throw NSError(
                domain: "SuggestWishIntent",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "No suggestions"]
            )
        }
        return .init(title: suggestion.title, notes: suggestion.notes)
    }

    func perform() async throws -> some ReturnsValue<String> {
        let wish = try await Self.perform(text)
        return .result(value: wish.title)
    }
}
