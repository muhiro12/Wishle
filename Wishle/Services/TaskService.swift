//
//  TaskService.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import Foundation
import SwiftData

/// A protocol that defines operations for managing `Wish` instances.
protocol TaskServiceProtocol {
    /// Adds a new task and persists it.
    /// - Returns: The created task instance.
    func addTask(title: String, notes: String?, dueDate: Date?, priority: Int) async throws -> Wish

    /// Finds a task for the given identifier.
    func task(id: UUID) -> Wish?

    /// Persists updates to the provided task.
    func updateTask(_ task: Wish) async throws

    /// Deletes the task from persistence.
    func deleteTask(_ task: Wish) async throws

    /// Returns the next task that is not completed, ordered by due date then priority.
    func nextUpTask() -> Wish?

    /// Underlying SwiftData context for advanced operations.
    var context: ModelContext { get }
}

/// Default implementation of ``TaskServiceProtocol`` using SwiftData.
@MainActor
final class TaskService: TaskServiceProtocol {
    /// Shared singleton instance used when no dependency is injected.
    static var shared: TaskService = {
        do {
            let schema = Schema([
                Wish.self,
                Tag.self
            ])
            let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            let container = try ModelContainer(for: schema, configurations: [configuration])
            return .init(modelContext: container.mainContext)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    /// The underlying SwiftData context.
    private let modelContext: ModelContext

    /// Exposes the underlying context for advanced operations.
    var context: ModelContext { modelContext }

    /// Creates an instance with the given model context.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func task(id: UUID) -> Wish? {
        let descriptor = FetchDescriptor<Wish>(predicate: #Predicate { $0.id == id })
        return try? modelContext.fetch(descriptor).first
    }

    func addTask(title: String, notes: String?, dueDate: Date?, priority: Int) throws -> Wish {
        let task = Wish(title: title, notes: notes, dueDate: dueDate, priority: priority)
        modelContext.insert(task)
        try modelContext.save()
        return task
    }

    func updateTask(_ task: Wish) throws {
        task.updatedAt = .now
        try modelContext.save()
    }

    func deleteTask(_ task: Wish) throws {
        modelContext.delete(task)
        try modelContext.save()
    }

    func nextUpTask() -> Wish? {
        let descriptor = FetchDescriptor<Wish>(predicate: #Predicate { !$0.isCompleted })
        guard let tasks = try? modelContext.fetch(descriptor) else {
            return nil
        }
        return tasks.sorted { lhs, rhs in
            switch (lhs.dueDate, rhs.dueDate) {
            case let (lhsDate?, rhsDate?):
                if lhsDate != rhsDate {
                    return lhsDate < rhsDate
                }
                return lhs.priority > rhs.priority
            case (nil, nil):
                return lhs.priority > rhs.priority
            case (nil, _):
                return false
            case (_, nil):
                return true
            }
        }.first
    }
}
