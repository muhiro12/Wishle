//
//  ChatView.swift
//  Wishle
//
//  Created by Codex on 2025/06/19.

import SwiftData
import SwiftUI

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            chatBubble(for: message)
                                .id(message.id)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let last = messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(last, anchor: .bottom)
                        }
                    }
                }
            }
            Divider()
            HStack {
                TextField("Enter wish", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                Button("Send") {
                    send()
                }
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
                .padding(8)
                .background(message.isUser ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8))
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
        let userMessage = ChatMessage(text: trimmed, isUser: true)
        messages.append(userMessage)
        inputText = ""

        Task {
            let wish = try? await AddWishIntent.perform((
                context: modelContext,
                title: trimmed,
                notes: nil,
                dueDate: nil,
                priority: 0
            ))
            let responseText: String
            if let wish {
                responseText = "Added: \(wish.title)"
            } else {
                responseText = "Failed to add wish"
            }
            let botMessage = ChatMessage(text: responseText, isUser: false)
            messages.append(botMessage)
        }
    }
}

#Preview {
    ChatView()
        .modelContainer(for: WishModel.self, inMemory: true)
}
