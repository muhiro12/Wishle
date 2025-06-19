//
//  DeleteTaskIntent.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct DeleteTaskIntent: AppIntent, IntentPerformer {
    static var title: LocalizedStringResource = "Delete Task"

    /// Service injected from the application context.
    var service: TaskServiceProtocol = TaskService.shared
    @Dependency private var modelContainer: ModelContainer

    @Parameter(title: "ID")
    private var id: String

    static var parameterSummary: some ParameterSummary {
        Summary("Delete task \(\.$id)")
    }

    typealias Input = (context: ModelContext, id: String)
    typealias Output = Void

    static func perform(_ input: Input) async throws {
        let (context, id) = input
        let service = TaskService(modelContext: context)
        guard let task = service.task(id: id) else {
            return
        }
        try await service.deleteTask(task)
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        try await Self.perform((
            context: modelContainer.mainContext,
            id: id
        ))
        return .result()
    }
}
