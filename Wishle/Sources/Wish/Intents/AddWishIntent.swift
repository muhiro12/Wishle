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
    static var title: LocalizedStringResource = "Add Wish"

    /// Service injected from the application context.
    var service: WishServiceProtocol = WishService.shared
    @Dependency private var modelContainer: ModelContainer

    @Parameter(title: "Title")
    private var title: String

    @Parameter(title: "Notes")
    private var notes: String?

    @Parameter(title: "Due Date")
    private var dueDate: Date?

    @Parameter(title: "Priority", default: 0)
    private var priority: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$title)") {
            \.$notes
            \.$dueDate
            \.$priority
        }
    }

    typealias Input = (context: ModelContext, title: String, notes: String?, dueDate: Date?, priority: Int)
    typealias Output = Wish

    static func perform(_ input: Input) async throws -> Wish {
        let (context, title, notes, dueDate, priority) = input
        let service = WishService(modelContext: context)
        return try await service.addWish(title: title, notes: notes, dueDate: dueDate, priority: priority)
    }

    @MainActor
    func perform() async throws -> some ReturnsValue<String> {
        let wish = try await Self.perform((
            context: modelContainer.mainContext,
            title: title,
            notes: notes,
            dueDate: dueDate,
            priority: priority
        ))
        return .result(value: wish.title)
    }
}
