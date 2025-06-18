import Foundation
import FoundationModels

@Generable
private struct TaskSuggestion: Decodable {
    var title: String
    var notes: String?
}

/// The context used for generating task suggestions.
struct SuggestionContext: Sendable {
    /// Free-form text describing the user's situation.
    var text: String
}

/// Service that generates task suggestions using an on-device foundation model.
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

    /// Generates task suggestions for the provided context.
    func suggestTasks(for context: SuggestionContext) async throws -> [Wish] {
        let prompt = promptTemplate.replacingOccurrences(of: "{{context}}", with: context.text)
        let response = try await session.respond(to: prompt, generating: [TaskSuggestion].self)
        return response.content.map { Wish(title: $0.title, notes: $0.notes) }
    }
}
