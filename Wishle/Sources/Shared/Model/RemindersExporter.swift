//
//  RemindersExporter.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import EventKit
import SwiftData

@MainActor
struct RemindersExporter {
    private let eventStore: EKEventStore
    private let service: TaskServiceProtocol

    init(eventStore: EKEventStore = .init(),
         service: TaskServiceProtocol) {
        self.eventStore = eventStore
        self.service = service
    }

    func export() async throws {
        try await eventStore.requestFullAccessToReminders()
        let models = try service.context.fetch(FetchDescriptor<WishModel>())
        for model in models {
            let task = model.wish
            for tag in task.tags {
                let calendar = try fetchOrCreateCalendar(name: tag.name)
                if let reminder = try await findReminder(for: task, in: calendar) {
                    let lastModified = reminder.lastModifiedDate ?? .distantPast
                    if task.updatedAt > lastModified {
                        update(reminder: reminder, from: task, calendar: calendar)
                        try eventStore.save(reminder, commit: false)
                    }
                } else {
                    let reminder = EKReminder(eventStore: eventStore)
                    update(reminder: reminder, from: task, calendar: calendar)
                    try eventStore.save(reminder, commit: false)
                }
            }
        }
        try eventStore.commit()
    }

    private func fetchOrCreateCalendar(name: String) throws -> EKCalendar {
        if let calendar = eventStore.calendars(for: .reminder).first(where: { $0.title == name }) {
            return calendar
        }
        let calendar = EKCalendar(for: .reminder, eventStore: eventStore)
        calendar.title = name
        if let source = eventStore.defaultCalendarForNewReminders()?.source {
            calendar.source = source
        } else if let newEventCalendar = eventStore.defaultCalendarForNewEvents {
            calendar.source = newEventCalendar.source
        } else {
            throw NSError(domain: "RemindersExporter", code: 1, userInfo: [NSLocalizedDescriptionKey: "No valid calendar source found."])
        }
        try eventStore.saveCalendar(calendar, commit: false)
        return calendar
    }

    private func findReminder(for task: Wish, in calendar: EKCalendar) async throws -> EKReminder? {
        let predicate = eventStore.predicateForReminders(in: [calendar])
        let reminders: [EKReminder] = try await withCheckedThrowingContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { fetchedReminders in
                if let reminders = fetchedReminders {
                    continuation.resume(returning: reminders)
                } else {
                    continuation.resume(returning: [])
                }
            }
        }
        return reminders.first { reminder in
            reminder.title == task.title && reminder.dueDateComponents?.date == task.dueDate
        }
    }

    private func update(reminder: EKReminder, from task: Wish, calendar: EKCalendar) {
        reminder.calendar = calendar
        reminder.title = task.title
        reminder.notes = task.notes
        reminder.priority = Int(task.priority)
        if let dueDate = task.dueDate {
            reminder.dueDateComponents = Calendar.current.dateComponents([
                .year, .month, .day, .hour, .minute
            ], from: dueDate)
        } else {
            reminder.dueDateComponents = nil
        }
        reminder.isCompleted = task.isCompleted
    }
}
