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
    @State private var isSending: Bool = false
    @State private var isPresentingAddSheet: Bool = false
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
                .scrollDismissesKeyboard(.interactively)
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
                .disabled(
                    inputText.trimmingCharacters(in: .whitespaces).isEmpty ||
                        isSending
                )
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
                    messages.append(
                        .init(
                            text: String(localized: "Debug mode enabled."),
                            isUser: false
                        )
                    )
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $isPresentingAddSheet) {
            if let wish = pendingWish {
                AddWishView(title: wish.title, notes: wish.notes ?? "", priority: wish.priority)
            }
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
            isSending = true
            do {
                let responseText: String
                if pendingWish != nil {
                    if trimmed.lowercased().contains("yes") ||
                        trimmed.lowercased().contains("add") {
                        isPresentingAddSheet = true
                        responseText = String(localized: "Opening the form.")
                    } else if trimmed.lowercased().contains("no") ||
                                trimmed.lowercased().contains("cancel") {
                        responseText = String(
                            localized: "Okay, let me know if you change your mind."
                        )
                        pendingWish = nil
                    } else {
                        responseText = try await SendChatMessageIntent.perform(trimmed)
                    }
                } else if trimmed.lowercased().contains("ok") ||
                            trimmed.lowercased().contains("looks good") ||
                            trimmed.lowercased().contains("done") {
                    if let wish = try? await SummarizeChatIntent.perform(()) {
                        pendingWish = wish
                        let format = NSLocalizedString(
                            "Shall I create \"%@\"?",
                            comment: "Prompt to confirm wish creation"
                        )
                        responseText = String(format: format, wish.title)
                    } else {
                        responseText = String(localized: "I couldn't summarize the wish.")
                    }
                } else {
                    responseText = try await SendChatMessageIntent.perform(trimmed)
                }
                withAnimation(.spring()) {
                    messages.append(.init(text: responseText, isUser: false))
                }
            } catch {
                let text: String
                if isDebugMode {
                    text = error.localizedDescription
                } else {
                    text = String(localized: "Something went wrong.")
                }
                withAnimation(.spring()) {
                    messages.append(.init(text: text, isUser: false))
                }
            }
            isSending = false
        }
    }
}

#Preview {
    ChatView()
        .modelContainer(for: WishModel.self, inMemory: true)
}
