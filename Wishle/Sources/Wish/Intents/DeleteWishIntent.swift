//
//  DeleteWishIntent.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents
@preconcurrency import SwiftData
import SwiftUtilities

struct DeleteWishIntent: AppIntent, IntentPerformer {
    static var title: LocalizedStringResource = "Delete Wish"

    @Dependency private var modelContainer: ModelContainer

    @Parameter(title: "ID")
    private var id: String

    static var parameterSummary: some ParameterSummary {
        Summary("Delete wish \(\.$id)")
    }

    typealias Input = (context: ModelContext, id: String)
    typealias Output = Void

    static func perform(_ input: Input) throws {
        let (context, id) = input
        let descriptor = FetchDescriptor<WishModel>(predicate: #Predicate {
            $0.id == id
        })
        guard let model = try context.fetch(descriptor).first else {
            return
        }
        context.delete(model)
        try context.save()
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        try Self.perform((
            context: modelContainer.mainContext,
            id: id
        ))
        return .result()
    }
}
