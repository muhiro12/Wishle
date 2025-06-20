import Foundation
import FoundationModels

@Generable
private struct WishSuggestion: Decodable {
    var title: String
    var notes: String?
}

/// The context used for generating wish suggestions.
struct SuggestionContext: Sendable {
    /// Free-form text describing the user's situation.
    var text: String
}

/// Service that generates wish suggestions using an on-device foundation model.
@MainActor
final class AISuggestionService {
    static let shared = AISuggestionService()

    private let session: LanguageModelSession
    private let promptTemplate: String

    init() {
        self.session = LanguageModelSession()
        if let url = Bundle.main.url(forResource: "suggestion_template", withExtension: "txt", subdirectory: "Prompts"),
           let template = try? String(contentsOf: url, encoding: .utf8) {
            promptTemplate = template
        } else {
            promptTemplate = ""
        }
    }

    /// Generates wish suggestions for the provided context.
    func suggestWishes(for context: SuggestionContext) async throws -> [Wish] {
        let prompt = promptTemplate.replacingOccurrences(of: "{{context}}", with: context.text)
        let response = try await session.respond(to: prompt, generating: [WishSuggestion].self)
        return response.content.map { suggestion in
            Wish(title: suggestion.title, notes: suggestion.notes)
        }
    }
}
