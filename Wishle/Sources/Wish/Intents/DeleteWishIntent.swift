//
//  DeleteWishIntent.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import AppIntents
import SwiftData
import SwiftUtilities

struct DeleteWishIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, id: String)
    typealias Output = Void

    @Parameter(title: "ID")
    private var id: String

    @Dependency private var modelContainer: ModelContainer

    static var title: LocalizedStringResource = "Delete Wish"

    static var parameterSummary: some ParameterSummary {
        Summary("Delete wish \(\.$id)")
    }

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
    func perform() throws -> some IntentResult {
        try Self.perform((
            context: modelContainer.mainContext,
            id: id
        ))
        return .result()
    }
}
