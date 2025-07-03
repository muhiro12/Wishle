//
//  ImportRemindersIntent.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct ImportRemindersIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContainer
    typealias Output = Void

    @Dependency private var modelContainer: ModelContainer

    static var title: LocalizedStringResource = "Import Reminders"

    static func perform(_ container: ModelContainer) async throws {
        let importer: RemindersImporter = .init(modelContainer: container)
        try await importer.import()
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        try await Self.perform(modelContainer)
        return .result()
    }
}
