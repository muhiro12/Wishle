//
//  RemindersImporter.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import EventKit
import SwiftData

@MainActor
struct RemindersImporter {
    private let eventStore: EKEventStore
    private let modelContainer: ModelContainer

    init(eventStore: EKEventStore = .init(), modelContainer: ModelContainer) {
        self.eventStore = eventStore
        self.modelContainer = modelContainer
    }

    func `import`() async throws {
        try await requestFullAccessToRemindersAsync()
        let calendars = eventStore.calendars(for: .reminder)
        for calendar in calendars {
            let tag = try fetchOrCreateTag(name: calendar.title)
            let predicate = eventStore.predicateForReminders(in: [calendar])
            let reminders = try await fetchRemindersAsync(matching: predicate)
            for reminder in reminders {
                guard let title = reminder.title else {
                    continue
                }
                let dueDate = reminder.dueDateComponents?.date
                let notes = reminder.notes
                let priority = Int(reminder.priority)
                if let existing = try findWish(for: reminder, tag: tag) {
                    if let lastModified = reminder.lastModifiedDate,
                       lastModified > existing.updatedAt {
                        try UpdateWishIntent.perform((
                            container: modelContainer,
                            id: existing.id,
                            title: title,
                            notes: notes,
                            dueDate: dueDate,
                            isCompleted: reminder.isCompleted,
                            priority: priority
                        ))
                    }
                } else {
                    var wish = try AddWishIntent.perform((
                        container: modelContainer,
                        title: title,
                        notes: notes,
                        dueDate: dueDate,
                        priority: priority
                    ))
                    wish.isCompleted = reminder.isCompleted
                    wish.tags.append(tag)
                    try UpdateWishIntent.perform((
                        container: modelContainer,
                        id: wish.id,
                        title: nil,
                        notes: nil,
                        dueDate: nil,
                        isCompleted: wish.isCompleted,
                        priority: wish.priority
                    ))
                    // Update tags directly
                    let id = wish.id
                    if let model = try? modelContainer.mainContext.fetch(
                        FetchDescriptor<WishModel>(predicate: #Predicate {
                            $0.id == id
                        })
                    ).first {
                        model.tags.append(TagModel(tag))
                        try modelContainer.mainContext.save()
                    }
                }
            }
        }
    }

    private func fetchOrCreateTag(name: String) throws -> Tag {
        let lowercasedName = name.lowercased()
        let descriptor = FetchDescriptor<TagModel>(predicate: #Predicate {
            $0.name == lowercasedName
        })
        if let model = try modelContainer.mainContext.fetch(descriptor).first {
            return model.tag
        }
        let model = TagModel(name: name)
        modelContainer.mainContext.insert(model)
        try modelContainer.mainContext.save()
        return model.tag
    }

    private func findWish(for reminder: EKReminder, tag: Tag) throws -> Wish? {
        guard let title = reminder.title else {
            return nil
        }
        let descriptor = FetchDescriptor<WishModel>(predicate: #Predicate {
            $0.title == title
        })
        let models = try modelContainer.mainContext.fetch(descriptor)
        let dueDate = reminder.dueDateComponents?.date
        return models.map(\.wish).first { wish in
            wish.dueDate == dueDate && wish.tags.contains(tag)
        }
    }

    private func requestFullAccessToRemindersAsync() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            eventStore.requestFullAccessToReminders { granted, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if granted {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: NSError(domain: "RemindersImporter", code: 1, userInfo: [NSLocalizedDescriptionKey: "Access to Reminders was not granted."]))
                }
            }
        }
    }

    private func fetchRemindersAsync(matching predicate: NSPredicate) async throws -> [EKReminder] {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[EKReminder], Error>) in
            eventStore.fetchReminders(matching: predicate) { reminders in
                if let reminders {
                    continuation.resume(returning: reminders)
                } else {
                    continuation.resume(throwing: NSError(domain: "RemindersImporter", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch reminders."]))
                }
            }
        }
    }
}
