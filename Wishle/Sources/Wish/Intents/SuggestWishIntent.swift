//
//  SuggestWishIntent.swift
//  Wishle
//
//  Created by Codex on 2025/06/20.
//

import AppIntents
import FoundationModels
import SwiftUtilities

@Generable
private struct WishSuggestion: Decodable {
    @Guide(description: "Title for the suggested wish")
    var title: String
    @Guide(description: "Optional notes about the wish")
    var notes: String?
}

struct SuggestWishIntent: AppIntent, IntentPerformer {
    typealias Input = String
    typealias Output = Wish

    @Parameter(title: "Context")
    private var text: String

    nonisolated static let title: LocalizedStringResource = "Suggest Wish"

    private static var promptTemplate: String {
        """
        You are Wishle, a helpful assistant that suggests new wishes based on user input.
        Provide one suggestion and respond only with a JSON object like:
        {
          \"title\": \"<wish title>\",
          \"notes\": \"<optional notes>\"
        }
        Do not add any text outside this JSON object.
        Respond in the user's device language: {{language}}.
        Context: {{context}}
        """
    }

    static func perform(_ input: Input) async throws -> Wish {
        let language = Locale.current.language.languageCode?.identifier ?? Locale.current.identifier
        let prompt = promptTemplate
            .replacingOccurrences(of: "{{context}}", with: input)
            .replacingOccurrences(of: "{{language}}", with: language)
        let session = LanguageModelSession()
        do {
            let response = try await session.respond(
                to: prompt,
                generating: WishSuggestion.self
            )
            return .init(
                title: response.content.title,
                notes: response.content.notes
            )
        } catch {
            let text = try await LanguageModelSession().respond(to: prompt).content
            guard
                let data = text.data(using: .utf8),
                let fallback = try? JSONDecoder().decode(WishSuggestion.self, from: data)
            else {
                throw error
            }
            return .init(title: fallback.title, notes: fallback.notes)
        }
    }

    func perform() async throws -> some ReturnsValue<String> {
        let wish = try await Self.perform(text)
        return .result(value: wish.title)
    }
}
