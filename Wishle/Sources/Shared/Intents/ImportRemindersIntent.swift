//
//  ImportRemindersIntent.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents
import SwiftUtilities

struct ImportRemindersIntent: AppIntent, IntentPerformer {
    static var title: LocalizedStringResource = "Import Reminders"

    @Dependency private var modelContainer: ModelContainer

    typealias Input = RemindersImporter
    typealias Output = Void

    static func perform(_ input: RemindersImporter) async throws {
        try await input.import()
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        let importer: RemindersImporter = .init(modelContext: modelContainer.mainContext)
        try await Self.perform(importer)
        return .result()
    }
}
