//
//  ChatMessage.swift
//  Wishle
//
//  Created by Codex on 2025/06/19.

import Foundation

struct ChatMessage: Identifiable, Hashable {
    var id: String = UUID().uuidString
    var text: String
    var isUser: Bool
}

