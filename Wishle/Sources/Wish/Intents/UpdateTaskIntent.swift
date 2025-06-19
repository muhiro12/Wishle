//
//  UpdateTaskIntent.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct UpdateTaskIntent: AppIntent, IntentPerformer {
    static var title: LocalizedStringResource = "Update Task"

    /// Service injected from the application context.
    var service: TaskServiceProtocol = TaskService.shared
    @Dependency private var modelContainer: ModelContainer

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

    static var parameterSummary: some ParameterSummary {
        Summary("Update task \(\.$id)") {
            \.$title
            \.$notes
            \.$dueDate
            \.$isCompleted
            \.$priority
        }
    }

    typealias Input = (context: ModelContext, id: String, title: String?, notes: String?, dueDate: Date?, isCompleted: Bool?, priority: Int?)
    typealias Output = Void

    static func perform(_ input: Input) async throws {
        let (context, id, title, notes, dueDate, isCompleted, priority) = input
        let service = TaskService(modelContext: context)
        guard var task = service.task(id: id) else {
            return
        }
        if let title { task.title = title }
        if let notes { task.notes = notes }
        if let dueDate { task.dueDate = dueDate }
        if let isCompleted { task.isCompleted = isCompleted }
        if let priority { task.priority = priority }
        try await service.updateTask(task)
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        try await Self.perform((
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
