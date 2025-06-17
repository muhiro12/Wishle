//
//  NextUpWidget.swift
//  WishleWidget
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import SwiftUI
import WidgetKit

struct NextUpProvider: TimelineProvider {
    func placeholder(in _: Context) -> NextUpEntry {
        .init(date: .now, task: .placeholder)
    }

    func getSnapshot(in _: Context, completion: @escaping (NextUpEntry) -> Void) {
        completion(.init(date: .now, task: .placeholder))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<NextUpEntry>) -> Void) {
        let task = TaskService.shared.nextUpTask()
        let entry = NextUpEntry(date: .now, task: task)
        let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 60 * 15)))
        completion(timeline)
    }
}

struct NextUpEntry: TimelineEntry {
    let date: Date
    let task: Task?
}

struct NextUpWidgetEntryView: View {
    var entry: NextUpProvider.Entry
    @Environment(\.widgetFamily) private var widgetFamily

    var body: some View {
        switch widgetFamily {
        case .accessoryInline:
            content
        default:
            content
                .padding()
        }
    }

    private var content: some View {
        VStack(alignment: .leading) {
            if let task = entry.task {
                Text(task.title)
                    .font(.headline)
                if let dueDate = task.dueDate {
                    Text(dueDate, style: .date)
                        .font(.caption)
                }
            } else {
                Text("No tasks")
            }
        }
    }
}

struct NextUpWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "NextUpWidget", provider: NextUpProvider()) { entry in
            NextUpWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .accessoryInline])
        .configurationDisplayName("Next Up")
        .description("Shows your next uncompleted task")
    }
}

extension Task {
    fileprivate static var placeholder: Task {
        .init(title: "Sample", notes: nil, dueDate: .now.addingTimeInterval(3600), priority: 0)
    }
}

#if DEBUG
#Preview(as: .systemSmall) {
    NextUpWidget()
} timeline: {
    NextUpEntry(date: .now, task: .placeholder)
}
#endif
