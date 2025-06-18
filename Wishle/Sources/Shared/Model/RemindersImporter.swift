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
    private let service: TaskServiceProtocol

    init(eventStore: EKEventStore = .init(), service: TaskServiceProtocol? = nil) {
        self.eventStore = eventStore
        self.service = service ?? TaskService.shared
    }

    func `import`() async throws {
        try await requestFullAccessToRemindersAsync()
        let calendars = eventStore.calendars(for: .reminder)
        for calendar in calendars {
            let tag = try fetchOrCreateTag(name: calendar.title)
            let predicate = eventStore.predicateForReminders(in: [calendar])
            let reminders = try await fetchRemindersAsync(matching: predicate)
            for reminder in reminders {
                guard let title = reminder.title else { continue }
                let dueDate = reminder.dueDateComponents?.date
                let notes = reminder.notes
                let priority = Int(reminder.priority)
                if let existing = try findTask(for: reminder, tag: tag) {
                    if let lastModified = reminder.lastModifiedDate,
                       lastModified > existing.updatedAt {
                        try await UpdateTaskIntent.perform((
                            context: service.context,
                            id: existing.id.uuidString,
                            title: title,
                            notes: notes,
                            dueDate: dueDate,
                            isCompleted: reminder.isCompleted,
                            priority: priority
                        ))
                    }
                } else {
                    var task = try await AddTaskIntent.perform((
                        context: service.context,
                        title: title,
                        notes: notes,
                        dueDate: dueDate,
                        priority: priority
                    ))
                    task.isCompleted = reminder.isCompleted
                    task.tags.append(tag)
                    try await service.updateTask(task)
                }
            }
        }
    }

    private func fetchOrCreateTag(name: String) throws -> Tag {
        let lowercasedName = name.lowercased()
        let descriptor = FetchDescriptor<Tag>(predicate: #Predicate { $0.name == lowercasedName })
        if let tag = try service.context.fetch(descriptor).first {
            return tag
        }
        let tag = Tag(name: name)
        service.context.insert(tag)
        try service.context.save()
        return tag
    }

    private func findTask(for reminder: EKReminder, tag: Tag) throws -> Wish? {
        guard let title = reminder.title else { return nil }
        let descriptor = FetchDescriptor<WishModel>(predicate: #Predicate { $0.title == title })
        let models = try service.context.fetch(descriptor)
        let dueDate = reminder.dueDateComponents?.date
        return models.map { $0.wish }.first { $0.dueDate == dueDate && $0.tags.contains(tag) }
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
