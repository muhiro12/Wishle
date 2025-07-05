//
//  UpdateWishIntent.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents
import SwiftData
import SwiftUtilities
import UserNotifications

struct UpdateWishIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, id: String, title: String?, notes: String?, dueDate: Date?, isCompleted: Bool?, priority: Int?)
    typealias Output = Void

    @Parameter(title: "ID")
    private var id: String

    @Parameter(title: "Title")
    private var title: String?

    @Parameter(title: "Notes")
    private var notes: String?

    @Parameter(title: "Due Date")
    private var dueDate: Date?

    @Parameter(title: "Is Completed")
    private var isCompleted: Bool?

    @Parameter(title: "Priority")
    private var priority: Int?

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = "Update Wish"

    static func perform(_ input: Input) throws {
        let (context, id, title, notes, dueDate, isCompleted, priority) = input
        let descriptor = FetchDescriptor<WishModel>(predicate: #Predicate {
            $0.id == id
        })
        guard let model = try context.fetch(descriptor).first else {
            return
        }
        if let title {
            model.title = title
        }
        if let notes {
            model.notes = notes
        }
        if let dueDate {
            model.dueDate = dueDate
        }
        if let isCompleted {
            model.isCompleted = isCompleted
        }
        if let priority {
            model.priority = priority
        }
        model.updatedAt = .now
        try context.save()
        NotificationManager.shared.removeDeadlineNotification(for: model.id)
        NotificationManager.shared.scheduleDeadlineNotification(for: model, daysBefore: 1)
    }

    func perform() throws -> some IntentResult {
        try Self.perform((
            context: modelContainer.mainContext,
            id: id,
            title: title,
            notes: notes,
            dueDate: dueDate,
            isCompleted: isCompleted,
            priority: priority
        ))
        return .result()
    }
}
