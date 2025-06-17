//
//  NextUpWidgetLiveActivity.swift
//  WishleWidget
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct NextUpAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var taskId: UUID
    }

    var name: String
}

struct NextUpWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NextUpAttributes.self) { context in
            VStack {
                Text("Next: \(context.state.taskId.uuidString.prefix(4))")
            }
        } dynamicIsland: { _ in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    Text("Next Up")
                }
            } compactLeading: {
                Text("Next")
            } compactTrailing: {
                Text("Up")
            } minimal: {
                Text("🎯")
            }
        }
    }
}

extension NextUpAttributes {
    fileprivate static var preview: NextUpAttributes { .init(name: "Preview") }
}

extension NextUpAttributes.ContentState {
    fileprivate static var sample: NextUpAttributes.ContentState { .init(taskId: .init()) }
}

#if DEBUG
#Preview("Notification", as: .content, using: NextUpAttributes.preview) {
    NextUpWidgetLiveActivity()
} contentStates: {
    NextUpAttributes.ContentState.sample
}
#endif
