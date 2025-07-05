//
//  NotificationManager.swift
//  Wishle
//
//  Created by Codex on 2025/07/25.
//

import Foundation
import SwiftData
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private let defaults = UserDefaults.standard

    private init() {}

    func requestAuthorization() async {
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    func scheduleDeadlineNotification(for model: WishModel, daysBefore: Int = 0) {
        guard let dueDate = model.dueDate else {
            return
        }
        guard let fireDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: dueDate),
              fireDate > .now else {
            return
        }
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "Wish Due"
        content.body = model.title
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: "wish-\(model.id)",
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    func removeDeadlineNotification(for id: String) {
        center.removePendingNotificationRequests(withIdentifiers: ["wish-\(id)"])
    }

    func scheduleDailySuggestion(at hour: Int = 9, minute: Int = 0) {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let content = UNMutableNotificationContent()
        content.title = "Wishle Suggestion"
        content.body = "Need inspiration? Tap to see a new wish idea."
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: "daily-suggestion",
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    func recordLaunch() {
        defaults.set(Date(), forKey: "lastLaunchDate")
    }

    func scheduleLaunchBasedSuggestion() {
        guard let lastLaunch = defaults.object(forKey: "lastLaunchDate") as? Date,
              let fireDate = Calendar.current.date(byAdding: .day, value: 1, to: lastLaunch),
              fireDate > .now else {
            return
        }
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: fireDate.timeIntervalSinceNow, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "Wishle Suggestion"
        content.body = "It\'s time for a new suggestion!"
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: "launch-suggestion",
            content: content,
            trigger: trigger
        )
        center.add(request)
    }
}
