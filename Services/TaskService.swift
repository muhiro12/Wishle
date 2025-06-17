//
//  TaskService.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import Foundation
import SwiftData

/// A protocol that defines operations for managing `Task` instances.
protocol TaskServiceProtocol {
    /// Adds a new task and persists it.
    /// - Returns: The created task instance.
    func addTask(title: String, notes: String?, dueDate: Date?, priority: Int) async throws -> Task

    /// Finds a task for the given identifier.
    func task(id: UUID) -> Task?

    /// Persists updates to the provided task.
    func updateTask(_ task: Task) async throws

    /// Deletes the task from persistence.
    func deleteTask(_ task: Task) async throws
}

/// Default implementation of ``TaskServiceProtocol`` using SwiftData.
@MainActor
final class TaskService: TaskServiceProtocol {
    /// Shared singleton instance used when no dependency is injected.
    static var shared: TaskService = {
        do {
            let schema = Schema([
                Task.self,
                Tag.self,
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

    /// Creates an instance with the given model context.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func task(id: UUID) -> Task? {
        let descriptor = FetchDescriptor<Task>(predicate: #Predicate { $0.id == id })
        return try? modelContext.fetch(descriptor).first
    }

    func addTask(title: String, notes: String?, dueDate: Date?, priority: Int) async throws -> Task {
        let task = Task(title: title, notes: notes, dueDate: dueDate, priority: priority)
        modelContext.insert(task)
        try modelContext.save()
        return task
    }

    func updateTask(_ task: Task) async throws {
        task.updatedAt = .now
        try modelContext.save()
    }

    func deleteTask(_ task: Task) async throws {
        modelContext.delete(task)
        try modelContext.save()
    }
}

