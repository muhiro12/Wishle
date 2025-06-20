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
    private let modelContext: ModelContext

    init(eventStore: EKEventStore = .init(),
         modelContext: ModelContext) {
        self.eventStore = eventStore
        self.modelContext = modelContext
    }

    func export() async throws {
        try await eventStore.requestFullAccessToReminders()
        let models = try modelContext.fetch(FetchDescriptor<WishModel>())
        for model in models {
            let wish = model.wish
            for tag in wish.tags {
                let calendar = try fetchOrCreateCalendar(name: tag.name)
                if let reminder = try await findReminder(for: wish, in: calendar) {
                    let lastModified = reminder.lastModifiedDate ?? .distantPast
                    if wish.updatedAt > lastModified {
                        update(reminder: reminder, from: wish, calendar: calendar)
                        try eventStore.save(reminder, commit: false)
                    }
                } else {
                    let reminder = EKReminder(eventStore: eventStore)
                    update(reminder: reminder, from: wish, calendar: calendar)
                    try eventStore.save(reminder, commit: false)
                }
            }
        }
        try eventStore.commit()
    }

    private func fetchOrCreateCalendar(name: String) throws -> EKCalendar {
        if let calendar = eventStore
            .calendars(for: .reminder)
            .first(where: { $0.title == name })
        {
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

    private func findReminder(for wish: Wish, in calendar: EKCalendar) async throws -> EKReminder? {
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
            reminder.title == wish.title && reminder.dueDateComponents?.date == wish.dueDate
        }
    }

    private func update(reminder: EKReminder, from wish: Wish, calendar: EKCalendar) {
        reminder.calendar = calendar
        reminder.title = wish.title
        reminder.notes = wish.notes
        reminder.priority = Int(wish.priority)
        if let dueDate = wish.dueDate {
            reminder.dueDateComponents = Calendar.current.dateComponents([
                .year, .month, .day, .hour, .minute
            ], from: dueDate)
        } else {
            reminder.dueDateComponents = nil
        }
        reminder.isCompleted = wish.isCompleted
    }
}
