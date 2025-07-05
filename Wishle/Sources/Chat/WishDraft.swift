//
//  WishDraft.swift
//  Wishle
//
//  Created by Codex on 2025/07/05.
//

import FoundationModels

@Generable
struct WishDraft: Decodable {
    @Guide(description: "Title for the wish")
    var title: String

    @Guide(description: "Optional notes about the wish")
    var notes: String?

    @Guide(description: "0 for normal priority, 1 for high")
    var priority: Int
}
