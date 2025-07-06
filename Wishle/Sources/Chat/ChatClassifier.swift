//
//  ChatClassifier.swift
//  Wishle
//
//  Created by Codex on 2025/07/08.
//  Copyright © 2025 Hiromu Nakano. All rights reserved.
//

import FoundationModels

enum ChatClassifier {
    enum Action {
        case confirm
        case cancel
        case complete
        case other
    }

    @Generable
    struct IntentResult: Decodable {
        @Guide(description: "One of confirm, cancel, complete, or other")
        var intent: String
    }

    static func classify(_ text: String) async throws -> Action {
        let prompt = PromptHelper.localized(
            """
            Determine whether the following user message confirms creating a wish,
            cancels it, indicates the conversation is complete, or is unrelated.
            Respond only with a JSON object like:
            {\"intent\": \"<confirm|cancel|complete|other>\"}
            Message: \(text)
            """
        )
        let session = LanguageModelSession()
        let result = try await session.respond(
            to: prompt,
            generating: IntentResult.self
        )
        switch result.content.intent.lowercased() {
        case "confirm":
            return .confirm
        case "cancel":
            return .cancel
        case "complete":
            return .complete
        default:
            return .other
        }
    }
}
