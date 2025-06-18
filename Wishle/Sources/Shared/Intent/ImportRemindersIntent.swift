//
//  ImportRemindersIntent.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents

struct ImportRemindersIntent: AppIntent {
    static var title: LocalizedStringResource = "Import Reminders"

    var importer: RemindersImporter = .init()

    func perform() async throws -> some IntentResult {
        try await importer.import()
        return .result()
    }
}
