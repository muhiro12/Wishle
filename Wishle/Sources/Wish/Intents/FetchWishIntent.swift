//
//  FetchWishIntent.swift
//  Wishle
//
//  Created by Codex on 2025/07/12.
//

import AppIntents
import SwiftData

struct FetchWishIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, id: String)
    typealias Output = WishModel?

    nonisolated static let title: LocalizedStringResource = "Fetch Wish"

    static func perform(_ input: Input) throws -> WishModel? {
        let (context, id) = input
        let descriptor = FetchDescriptor<WishModel>(predicate: #Predicate { $0.id == id })
        return try context.fetch(descriptor).first
    }
}

