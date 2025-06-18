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

    var importer: RemindersImporter = .init()

    typealias Input = RemindersImporter
    typealias Output = Void

    static func perform(_ input: Input) async throws -> Output {
        try await input.import()
    }

    func perform() async throws -> some IntentResult {
        try await Self.perform(importer)
        return .result()
    }
}
