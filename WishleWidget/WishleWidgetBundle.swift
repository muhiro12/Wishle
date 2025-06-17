//
//  WishleWidgetBundle.swift
//  WishleWidget
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import SwiftUI
import WidgetKit

@main
struct WishleWidgetBundle: WidgetBundle {
    var body: some Widget {
        WishleWidget()
        NextUpWidget()
        WishleWidgetControl()
        WishleWidgetLiveActivity()
        NextUpWidgetLiveActivity()
    }
}
