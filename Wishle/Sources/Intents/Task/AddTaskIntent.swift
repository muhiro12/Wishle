//
//  AddTaskIntent.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents
import SwiftUtilities

struct AddTaskIntent: AppIntent, IntentPerformer {
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

    typealias Input = (service: TaskServiceProtocol, title: String, notes: String?, dueDate: Date?, priority: Int)
    typealias Output = Void

    static func perform(_ input: Input) async throws -> Output {
        let (service, title, notes, dueDate, priority) = input
        _ = try await service.addTask(title: title, notes: notes, dueDate: dueDate, priority: priority)
    }

    func perform() async throws -> some IntentResult {
        try await Self.perform((service: service, title: title, notes: notes, dueDate: dueDate, priority: priority))
        return .result()
    }
}
