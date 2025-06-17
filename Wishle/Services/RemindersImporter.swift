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

    init(eventStore: EKEventStore = .init(),
         service: TaskServiceProtocol = TaskService.shared) {
        self.eventStore = eventStore
        self.service = service
    }

    func `import`() async throws {
        try await eventStore.requestFullAccessToReminders()
        let calendars = eventStore.calendars(for: .reminder)
        for calendar in calendars {
            let tag = try fetchOrCreateTag(name: calendar.title)
            let predicate = eventStore.predicateForReminders(in: [calendar])
            let reminders = try await eventStore.fetchReminders(matching: predicate)
            for reminder in reminders {
                guard let title = reminder.title else { continue }
                let dueDate = reminder.dueDateComponents?.date
                let notes = reminder.notes
                let priority = Int(reminder.priority)
                if let existing = try findTask(for: reminder, tag: tag) {
                    if let lastModified = reminder.lastModifiedDate,
                       lastModified > existing.updatedAt {
                        existing.title = title
                        existing.notes = notes
                        existing.dueDate = dueDate
                        existing.isCompleted = reminder.isCompleted
                        existing.priority = priority
                        try service.updateTask(existing)
                    }
                } else {
                    var task = try service.addTask(title: title,
                                                   notes: notes,
                                                   dueDate: dueDate,
                                                   priority: priority)
                    task.isCompleted = reminder.isCompleted
                    task.tags.append(tag)
                    try service.updateTask(task)
                }
            }
        }
    }

    private func fetchOrCreateTag(name: String) throws -> Tag {
        let descriptor = FetchDescriptor<Tag>(predicate: #Predicate { $0.name == name.lowercased() })
        if let tag = try service.context.fetch(descriptor).first {
            return tag
        }
        let tag = Tag(name: name)
        service.context.insert(tag)
        try service.context.save()
        return tag
    }

    private func findTask(for reminder: EKReminder, tag: Tag) throws -> Task? {
        guard let title = reminder.title else { return nil }
        let descriptor = FetchDescriptor<Task>(predicate: #Predicate { $0.title == title })
        guard let tasks = try service.context.fetch(descriptor) as [Task]? else { return nil }
        let dueDate = reminder.dueDateComponents?.date
        return tasks.first { $0.dueDate == dueDate && $0.tags.contains(tag) }
    }
}
