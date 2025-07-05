//
//  ChatView.swift
//  Wishle
//
//  Created by Codex on 2025/06/19.

import AppIntents
import Foundation
import SwiftData
import SwiftUI

struct ChatView: View {
    @Environment(\.modelContext) private var context

    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var pendingWish: Wish?
    @State private var isEnableDebugAlertPresented: Bool = false
    @AppStorage("isDebugMode") private var isDebugMode: Bool = false

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
        .confirmationDialog(
            "Enable debug mode?",
            isPresented: $isEnableDebugAlertPresented
        ) {
            Button("Enable", role: .destructive) {
                isDebugMode = true
                withAnimation(.spring()) {
                    messages.append(.init(text: "Debug mode enabled.", isUser: false))
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func chatBubble(for message: ChatMessage) -> some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            Text(message.text)
                .textSelection(.enabled)
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

        if trimmed.lowercased() == "enable debug" {
            isEnableDebugAlertPresented = true
            return
        }

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
                    responseText = await suggestWish(from: trimmed)
                }
            } else {
                responseText = await suggestWish(from: trimmed)
            }
            withAnimation(.spring()) {
                messages.append(.init(text: responseText, isUser: false))
            }
        }
    }

    private func suggestWish(from text: String) async -> String {
        do {
            let wish = try await SuggestWishIntent.perform(text)
            pendingWish = wish
            return "How about \"\(wish.title)\"?"
        } catch {
            if isDebugMode {
                return error.localizedDescription
            } else {
                return "I couldn't come up with a wish."
            }
        }
    }
}

#Preview {
    ChatView()
        .modelContainer(for: WishModel.self, inMemory: true)
}
