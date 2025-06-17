//
//  NextUpLiveActivity.swift
//  WishleWidget
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct NextUpLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var remainingTime: TimeInterval
    }

    var taskID: UUID
}

struct NextUpLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NextUpLiveActivityAttributes.self) { context in
            VStack(alignment: .leading) {
                Text("Next Task")
                Text(
                    timerInterval: Date()...Date().addingTimeInterval(context.state.remainingTime),
                    countsDown: true
                )
            }
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    Text(
                        timerInterval: Date()...Date().addingTimeInterval(context.state.remainingTime),
                        countsDown: true
                    )
                    .font(.headline)
                }
            } compactLeading: {
                Image(systemName: "checkmark.circle")
            } compactTrailing: {
                Text(
                    timerInterval: Date()...Date().addingTimeInterval(context.state.remainingTime),
                    countsDown: true
                )
            } minimal: {
                Image(systemName: "checkmark.circle")
            }
        }
    }
}

#if DEBUG
extension NextUpLiveActivityAttributes {
    fileprivate static var preview: NextUpLiveActivityAttributes {
        .init(taskID: .init())
    }
}

extension NextUpLiveActivityAttributes.ContentState {
    fileprivate static var sample: NextUpLiveActivityAttributes.ContentState {
        .init(remainingTime: 60)
    }
}

#Preview("Notification", as: .content, using: NextUpLiveActivityAttributes.preview) {
    NextUpLiveActivity()
} contentStates: {
    NextUpLiveActivityAttributes.ContentState.sample
}
#endif
