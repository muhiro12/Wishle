//
//  DeleteTaskIntent.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents

@available(iOS 19, macOS 15, *)
@AppIntent("Delete a task from Wishle")
struct DeleteTaskIntent {
    static var title: LocalizedStringResource = "Delete Task"

    /// Service injected from the application context.
    var service: TaskServiceProtocol = TaskService.shared

    @Parameter(title: "ID")
    var id: UUID

    static var parameterSummary: some ParameterSummary {
        Summary("Delete task \(\.$id)")
    }

    func perform() async throws -> some IntentResult {
        guard let task = service.task(id: id) else {
            return .result(value: .init())
        }
        try await service.deleteTask(task)
        return .result()
    }
}
