//
//  DeleteItemIntent.swift
//  Wishle
//
//  Created by Codex on 2025/07/12.
//

import AppIntents
import SwiftData

struct DeleteItemIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, item: Item)
    typealias Output = Void

    nonisolated static let title: LocalizedStringResource = "Delete Item"

    static func perform(_ input: Input) throws {
        let (context, item) = input
        context.delete(item)
        try context.save()
    }
}

