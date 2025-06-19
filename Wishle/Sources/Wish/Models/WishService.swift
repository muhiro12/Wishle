//
//  WishService.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import Foundation
import SwiftData

/// A protocol that defines operations for managing `Wish` instances.
protocol WishServiceProtocol {
    /// Adds a new wish and persists it.
    /// - Returns: The created wish instance.
    func addWish(title: String, notes: String?, dueDate: Date?, priority: Int) async throws -> Wish

    /// Finds a wish for the given identifier.
    func wish(id: String) -> Wish?

    /// Persists updates to the provided wish.
    func updateWish(_ wish: Wish) async throws

    /// Deletes the wish from persistence.
    func deleteWish(_ wish: Wish) async throws

    /// Returns the next wish that is not completed, ordered by due date then priority.
    func nextUpWish() -> Wish?

    /// Underlying SwiftData context for advanced operations.
    var context: ModelContext { get }
}

/// Default implementation of ``WishServiceProtocol`` using SwiftData.
@MainActor
final class WishService: WishServiceProtocol {
    /// Shared singleton instance used when no dependency is injected.
    static var shared: WishService = {
        do {
            let schema = Schema([
                WishModel.self,
                TagModel.self
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

    func wish(id: String) -> Wish? {
        let id = id
        let descriptor = FetchDescriptor<WishModel>(predicate: #Predicate { $0.id == id })
        guard let model = try? modelContext.fetch(descriptor).first else {
            return nil
        }
        return model.wish
    }

    func addWish(title: String, notes: String?, dueDate: Date?, priority: Int) throws -> Wish {
        let model = WishModel(
            title: title,
            notes: notes,
            dueDate: dueDate,
            priority: priority
        )
        modelContext.insert(model)
        try modelContext.save()
        return model.wish
    }

    func updateWish(_ wish: Wish) throws {
        let id = wish.id
        let descriptor = FetchDescriptor<WishModel>(predicate: #Predicate { $0.id == id })
        guard let model = try modelContext.fetch(descriptor).first else {
            return
        }

        model.title = wish.title
        model.notes = wish.notes
        model.dueDate = wish.dueDate
        model.isCompleted = wish.isCompleted
        model.priority = wish.priority
        model.updatedAt = .now
        model.tags = wish.tags.map(TagModel.init)
        try modelContext.save()
    }

    func deleteWish(_ wish: Wish) throws {
        let id = wish.id
        let descriptor = FetchDescriptor<WishModel>(predicate: #Predicate { $0.id == id })
        if let model = try modelContext.fetch(descriptor).first {
            modelContext.delete(model)
        }
        try modelContext.save()
    }

    func nextUpWish() -> Wish? {
        let descriptor = FetchDescriptor<WishModel>(predicate: #Predicate { !$0.isCompleted })
        guard let models = try? modelContext.fetch(descriptor) else {
            return nil
        }
        let wishes = models.map(\.wish)
        return wishes.sorted { lhs, rhs in
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
