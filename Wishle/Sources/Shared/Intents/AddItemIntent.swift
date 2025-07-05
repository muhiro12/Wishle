//
//  AddItemIntent.swift
//  Wishle
//
//  Created by Codex on 2025/07/12.
//

import AppIntents
import SwiftData

struct AddItemIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, timestamp: Date)
    typealias Output = Item

    nonisolated static let title: LocalizedStringResource = "Add Item"

    static func perform(_ input: Input) throws -> Item {
        let (context, timestamp) = input
        let item = Item(timestamp: timestamp)
        context.insert(item)
        try context.save()
        return item
    }
}

