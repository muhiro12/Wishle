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
    typealias Input = (container: ModelContainer, title: String, notes: String?, dueDate: Date?, priority: Int)
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

    static var title: LocalizedStringResource = "Add Wish"

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$title)") {
            \.$notes
            \.$dueDate
            \.$priority
        }
    }

    static func perform(_ input: Input) throws -> Wish {
        let (container, title, notes, dueDate, priority) = input
        let context = container.mainContext
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

    @MainActor
    func perform() throws -> some ReturnsValue<String> {
        let wish = try Self.perform((
            container: modelContainer,
            title: title,
            notes: notes,
            dueDate: dueDate,
            priority: priority
        ))
        return .result(value: wish.title)
    }
}
