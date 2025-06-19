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
    static var title: LocalizedStringResource = "Delete Wish"

    /// Service injected from the application context.
    var service: WishServiceProtocol = WishService.shared
    @Dependency private var modelContainer: ModelContainer

    @Parameter(title: "ID")
    private var id: String

    static var parameterSummary: some ParameterSummary {
        Summary("Delete wish \(\.$id)")
    }

    typealias Input = (context: ModelContext, id: String)
    typealias Output = Void

    static func perform(_ input: Input) async throws {
        let (context, id) = input
        let service = WishService(modelContext: context)
        guard let wish = service.wish(id: id) else {
            return
        }
        try await service.deleteWish(wish)
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        try await Self.perform((
            context: modelContainer.mainContext,
            id: id
        ))
        return .result()
    }
}
