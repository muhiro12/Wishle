//
//  UpdateTaskIntent.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents
import SwiftUtilities

struct UpdateTaskIntent: AppIntent, IntentPerformer {
    static var title: LocalizedStringResource = "Update Task"

    /// Service injected from the application context.
    var service: TaskServiceProtocol = TaskService.shared

    @Parameter(title: "ID")
    var id: String

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

    typealias Input = (service: TaskServiceProtocol, id: String, title: String?, notes: String?, dueDate: Date?, isCompleted: Bool?, priority: Int?)
    typealias Output = Void

    static func perform(_ input: Input) async throws -> Output {
        let (service, id, title, notes, dueDate, isCompleted, priority) = input
        guard let uuid = UUID(uuidString: id), var task = service.task(id: uuid) else { return }
        if let title { task.title = title }
        if let notes { task.notes = notes }
        if let priority { task.priority = priority }
        try await service.updateTask(task)
    }

    func perform() async throws -> some IntentResult {
        try await Self.perform((service: service, id: id, title: title, notes: notes, dueDate: dueDate, isCompleted: isCompleted, priority: priority))
        return .result()
    }
}
