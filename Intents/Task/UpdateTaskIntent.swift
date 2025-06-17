//
//  UpdateTaskIntent.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents

@available(iOS 19, macOS 15, *)
@AppIntent("Update a task in Wishle")
struct UpdateTaskIntent {
    static var title: LocalizedStringResource = "Update Task"

    /// Service injected from the application context.
    var service: TaskServiceProtocol = TaskService.shared

    @Parameter(title: "ID")
    var id: UUID

    @Parameter(title: "Title")
    var title: String?

    @Parameter(title: "Notes")
    var notes: String?

    @Parameter(title: "Due Date")
    var dueDate: Date?

    @Parameter(title: "Is Completed")
    var isCompleted: Bool?

    @Parameter(title: "Priority")
    var priority: Int?

    static var parameterSummary: some ParameterSummary {
        Summary("Update task \(\.$id)") {
            \.$title
            \.$notes
            \.$dueDate
            \.$isCompleted
            \.$priority
        }
    }

    func perform() async throws -> some IntentResult {
        guard let task = service.task(id: id) else {
            return .result(value: .init())
        }
        if let title { task.title = title }
        if let notes { task.notes = notes }
        if let dueDate { task.dueDate = dueDate }
        if let isCompleted { task.isCompleted = isCompleted }
        if let priority { task.priority = priority }
        try await service.updateTask(task)
        return .result()
    }
}

