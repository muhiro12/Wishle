import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

/// The context used for generating task suggestions.
struct SuggestionContext: Sendable {
    /// Free-form text describing the user's situation.
    var text: String
}

/// A single task suggestion returned by the model.
private struct TaskSuggestion: Decodable {
    var title: String
    var notes: String?
}

/// Service that generates task suggestions using an on-device foundation model.
@MainActor
final class AISuggestionService {
    static let shared = AISuggestionService()

    private let pipeline: ChatPipeline
    private let configuration: ChatGenerationConfig
    private let promptTemplate: String

    init(randomProvider: RandomProvider = SystemRandomProvider()) {
        configuration = .init(maxTokens: 64, temperature: 0.7)
        #if canImport(FoundationModels)
        pipeline = .init(model: .init(named: "local-llm"), randomProvider: randomProvider)
        #else
        pipeline = .init()
        #endif
        if let url = Bundle.main.url(forResource: "suggestion_template", ofType: "txt", inDirectory: "Prompts"),
           let template = try? String(contentsOf: url) {
            promptTemplate = template
        } else {
            promptTemplate = ""
        }
    }

    /// Generates task suggestions for the provided context.
    func suggestTasks(for context: SuggestionContext) async throws -> [Task] {
        var chat = Chat()
        let prompt = promptTemplate.replacingOccurrences(of: "{{context}}", with: context.text)
        chat.append(.user(prompt))
        let result = try await pipeline.generate(chat: chat, config: configuration)
        guard let text = result.choices.first?.message.content else { return [] }
        let data = Data(text.utf8)
        guard let suggestions = try? JSONDecoder().decode([TaskSuggestion].self, from: data) else { return [] }
        return suggestions.map { .init(title: $0.title, notes: $0.notes) }
    }
}
