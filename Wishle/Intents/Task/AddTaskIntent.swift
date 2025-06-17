//
//  AddTaskIntent.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents

@available(iOS 19, macOS 15, *)
@AppIntent("Add a task to Wishle")
struct AddTaskIntent {
    static var title: LocalizedStringResource = "Add Task"

    /// Service injected from the application context.
    var service: TaskServiceProtocol = TaskService.shared

    @Parameter(title: "Title")
    var title: String

    @Parameter(title: "Notes")
    var notes: String?

    @Parameter(title: "Due Date")
    var dueDate: Date?

    @Parameter(title: "Priority", default: 0)
    var priority: Int

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$title)") {
            \.$notes
            \.$dueDate
            \.$priority
        }
    }

    func perform() async throws -> some IntentResult {
        _ = try await service.addTask(title: title, notes: notes, dueDate: dueDate, priority: priority)
        return .result()
    }
}
