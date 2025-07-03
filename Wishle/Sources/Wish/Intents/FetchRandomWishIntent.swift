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
    typealias Input = ModelContainer
    typealias Output = Wish

    @Dependency private var modelContainer: ModelContainer

    static var title: LocalizedStringResource = "Get Random Wish"

    static func perform(_ container: ModelContainer) throws -> Wish {
        let models = try container.mainContext.fetch(FetchDescriptor<WishModel>())
        guard let model = models.randomElement() else {
            throw NSError(
                domain: "FetchRandomWishIntent",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "No wishes available"]
            )
        }
        return model.wish
    }

    @MainActor
    func perform() throws -> some ReturnsValue<String> {
        let wish = try Self.perform(modelContainer)
        return .result(value: wish.title)
    }
}
