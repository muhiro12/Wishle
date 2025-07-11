//
//  AppIntent.swift
//  WishleWidget
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents
import WidgetKit

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Configuration"
    static let description: IntentDescription = "This is an example widget."

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}
