//
//  FetchRandomWishIntent.swift
//  Wishle
//
//  Created by Codex on 2025/06/20.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct FetchRandomWishIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContext
    typealias Output = Wish

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = "Get Random Wish"

    static func perform(_ input: Input) throws -> Wish {
        let models = try input.fetch(FetchDescriptor<WishModel>())
        guard let model = models.randomElement() else {
            throw NSError(
                domain: "FetchRandomWishIntent",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "No wishes available"]
            )
        }
        return model.wish
    }

    func perform() throws -> some ReturnsValue<String> {
        let wish = try Self.perform(modelContainer.mainContext)
        return .result(value: wish.title)
    }
}
