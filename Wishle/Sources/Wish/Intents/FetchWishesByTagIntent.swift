//
//  FetchWishesByTagIntent.swift
//  Wishle
//
//  Created by Codex on 2025/07/12.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct FetchWishesByTagIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, tagID: String)
    typealias Output = [Wish]

    nonisolated static let title: LocalizedStringResource = "Fetch Wishes By Tag"

    @Parameter private var tagID: String

    @Dependency private var modelContaienr: ModelContainer

    static func perform(_ input: Input) throws -> [Wish] {
        let (context, tagID) = input
        let models = try context.fetch(FetchDescriptor<WishModel>())
        return models.filter { model in
            model.tags.contains { $0.id == tagID }
        }.map(\.wish)
    }

    func perform() throws -> some IntentResult {
        .result(
            value: try Self.perform((modelContaienr.mainContext, tagID))
        )
    }
}
