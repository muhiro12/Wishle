//
//  DeleteTaskIntent.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents

struct DeleteTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Delete Task"

    /// Service injected from the application context.
    var service: TaskServiceProtocol = TaskService.shared

    @Parameter(title: "ID")
    var id: String

    static var parameterSummary: some ParameterSummary {
        Summary("Delete task \(\.$id)")
    }

    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: id),
              let task = service.task(id: uuid) else {
            return .result()
        }
        try await service.deleteTask(task)
        return .result()
    }
}
