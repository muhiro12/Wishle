//
//  NextUpWidget.swift
//  WishleWidget
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import Foundation
import SwiftUI
import WidgetKit

struct NextUpProvider: TimelineProvider {
    func placeholder(in _: Context) -> NextUpEntry {
        .init(date: .now, wish: .placeholder)
    }

    func getSnapshot(in _: Context, completion: @escaping (NextUpEntry) -> Void) {
        completion(.init(date: .now, wish: .placeholder))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<NextUpEntry>) -> Void) {
        let wish = WishDataStore.shared.nextUpWish()
        let entry = NextUpEntry(date: .now, wish: wish)
        let timeline = Timeline(entries: [entry], policy: .after(.now.advanced(by: 60 * 15)))
        completion(timeline)
    }
}

struct NextUpEntry: TimelineEntry {
    let date: Date
    let wish: WidgetWish?
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
            if let wish = entry.wish {
                Text(wish.title)
                    .font(.headline)
                if let dueDate = wish.dueDate {
                    Text(dueDate, style: .date)
                        .font(.caption)
                }
            } else {
                Text("No wishes")
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
        .description("Shows your next uncompleted wish")
    }
}

#if DEBUG
#Preview(as: .systemSmall) {
    NextUpWidget()
} timeline: {
    NextUpEntry(date: .now, wish: .placeholder)
}
#endif
