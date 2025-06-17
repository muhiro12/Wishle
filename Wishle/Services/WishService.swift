import Foundation
import SwiftData

/// Protocol defining operations for managing wishes.
protocol WishServiceProtocol {
    /// Returns all wishes.
    func fetchWishes() throws -> [Wish]
    /// Adds a new wish and persists it.
    func addWish(title: String, notes: String?, dueDate: Date?, priority: Int) async throws -> Wish
    /// Finds a wish by identifier.
    func wish(id: UUID) -> Wish?
    /// Persists updates to the provided wish.
    func updateWish(_ wish: Wish) async throws
    /// Deletes the wish from persistence.
    func deleteWish(_ wish: Wish) async throws
    /// Returns the next wish that is not completed, ordered by due date then priority.
    func nextUpWish() -> Wish?
    /// Underlying SwiftData context for advanced operations.
    var context: ModelContext { get }
}

/// Default implementation of ``WishServiceProtocol`` wrapping ``TaskService``.
@MainActor final class WishService: WishServiceProtocol {
    static var shared = WishService(taskService: TaskService.shared)

    private let taskService: TaskServiceProtocol

    init(taskService: TaskServiceProtocol) {
        self.taskService = taskService
    }

    var context: ModelContext { taskService.context }

    func fetchWishes() throws -> [Wish] {
        try taskService.context.fetch(FetchDescriptor<Wish>())
    }

    func addWish(title: String, notes: String?, dueDate: Date?, priority: Int) async throws -> Wish {
        try await taskService.addTask(title: title, notes: notes, dueDate: dueDate, priority: priority)
    }

    func wish(id: UUID) -> Wish? {
        taskService.task(id: id)
    }

    func updateWish(_ wish: Wish) async throws {
        try await taskService.updateTask(wish)
    }

    func deleteWish(_ wish: Wish) async throws {
        try await taskService.deleteTask(wish)
    }

    func nextUpWish() -> Wish? {
        taskService.nextUpTask()
    }
}
