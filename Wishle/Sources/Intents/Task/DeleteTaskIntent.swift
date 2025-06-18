//
//  DeleteTaskIntent.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents
import SwiftUtilities

struct DeleteTaskIntent: AppIntent, IntentPerformer {
    static var title: LocalizedStringResource = "Delete Task"

    /// Service injected from the application context.
    var service: TaskServiceProtocol = TaskService.shared

    @Parameter(title: "ID")
    var id: String

    static var parameterSummary: some ParameterSummary {
        Summary("Delete task \(\.$id)")
    }

    typealias Input = (service: TaskServiceProtocol, id: String)
    typealias Output = Void

    static func perform(_ input: Input) async throws -> Output {
        let (service, id) = input
        guard let uuid = UUID(uuidString: id), let task = service.task(id: uuid) else {
            return
        }
        try await service.deleteTask(task)
    }

    func perform() async throws -> some IntentResult {
        try await Self.perform((service: service, id: id))
        return .result()
    }
}
