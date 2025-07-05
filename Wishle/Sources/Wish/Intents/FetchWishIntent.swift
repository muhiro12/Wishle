//
//  FetchWishIntent.swift
//  Wishle
//
//  Created by Codex on 2025/07/12.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct FetchWishIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, id: String)
    typealias Output = Wish?

    nonisolated static let title: LocalizedStringResource = "Fetch Wish"

    @Parameter private var id: String

    @Dependency private var modelContainer: ModelContainer

    static func perform(_ input: Input) throws -> Output {
        let (context, id) = input
        let descriptor = FetchDescriptor<WishModel>(predicate: #Predicate { $0.id == id })
        guard let model = try context.fetch(descriptor).first else {
            return nil
        }
        return .init(model)
    }

    func perform() throws -> some IntentResult {
        .result(
            value: try Self.perform((modelContainer.mainContext, id))
        )
    }
}
