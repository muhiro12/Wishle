//
//  ChatView.swift
//  Wishle
//
//  Created by Codex on 2025/06/19.

import Foundation
import SwiftData
import SwiftUI

struct ChatView: View {
    @Environment(\.modelContext) private var context

    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var pendingWish: Wish?

    private let suggestionService = AISuggestionService.shared

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            chatBubble(for: message)
                                .id(message.id)
                                .transition(
                                    .move(edge: message.isUser ? .trailing : .leading)
                                        .combined(with: .opacity)
                                )
                        }
                    }
                    .animation(.spring(), value: messages)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .onChange(of: messages.count) {
                    if let last = messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(last, anchor: .bottom)
                        }
                    }
                }
            }
            Divider()
            HStack(spacing: 12) {
                TextField("Enter message", text: $inputText)
                    .padding(.vertical, 8)
                    .liquidGlass(cornerRadius: 20)
                Button("Send") {
                    send()
                }
                .buttonStyle(.borderedProminent)
                .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding()
        }
    }

    private func chatBubble(for message: ChatMessage) -> some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            Text(message.text)
                .liquidGlass(cornerRadius: 20)
            if !message.isUser {
                Spacer()
            }
        }
    }

    private func send() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return
        }
        withAnimation(.spring()) {
            messages.append(.init(text: trimmed, isUser: true))
        }
        inputText = ""

        Task {
            let responseText: String
            if let wish = pendingWish {
                if trimmed.lowercased().contains("yes") ||
                    trimmed.lowercased().contains("add") {
                    let result = try? AddWishIntent.perform((
                        context: context,
                        title: wish.title,
                        notes: wish.notes,
                        dueDate: nil,
                        priority: wish.priority
                    ))
                    if let result {
                        responseText = "Added: \(result.title)"
                    } else {
                        responseText = "Failed to add wish"
                    }
                    pendingWish = nil
                } else if trimmed.lowercased().contains("no") ||
                            trimmed.lowercased().contains("cancel") {
                    responseText = "Okay, let me know if you change your mind."
                    pendingWish = nil
                } else {
                    let suggestions = try? await suggestionService.suggestWishes(
                        for: .init(text: trimmed)
                    )
                    if let suggestion = suggestions?.first {
                        pendingWish = suggestion
                        responseText = "How about \"\(suggestion.title)\"?"
                    } else {
                        responseText = "I couldn't come up with a wish."
                    }
                }
            } else {
                let suggestions = try? await suggestionService.suggestWishes(for: .init(text: trimmed))
                if let suggestion = suggestions?.first {
                    pendingWish = suggestion
                    responseText = "How about \"\(suggestion.title)\"?"
                } else {
                    responseText = "I couldn't come up with a wish."
                }
            }
            withAnimation(.spring()) {
                messages.append(.init(text: responseText, isUser: false))
            }
        }
    }
}

#Preview {
    ChatView()
        .modelContainer(for: WishModel.self, inMemory: true)
}
