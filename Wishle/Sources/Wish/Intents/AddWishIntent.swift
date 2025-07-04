//
//  AddWishIntent.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct AddWishIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, title: String, notes: String?, dueDate: Date?, priority: Int)
    typealias Output = Wish

    @Parameter(title: "Title")
    private var title: String

    @Parameter(title: "Notes")
    private var notes: String?

    @Parameter(title: "Due Date")
    private var dueDate: Date?

    @Parameter(title: "Priority", default: 0)
    private var priority: Int

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = "Add Wish"

    static func perform(_ input: Input) throws -> Wish {
        let (context, title, notes, dueDate, priority) = input
        let model = WishModel(
            title: title,
            notes: notes,
            dueDate: dueDate,
            priority: priority
        )
        context.insert(model)
        try context.save()
        return model.wish
    }

    func perform() throws -> some ReturnsValue<String> {
        let wish = try Self.perform((
            context: modelContainer.mainContext,
            title: title,
            notes: notes,
            dueDate: dueDate,
            priority: priority
        ))
        return .result(value: wish.title)
    }
}
