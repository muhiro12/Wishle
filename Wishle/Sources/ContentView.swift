//
//  ContentView.swift
//  Wishle
//
//  Created by Hiromu Nakano on 2025/06/17.
//

import SwiftData
import SwiftUI
#if os(iOS)
import UIKit
#endif

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    @State private var isUpdateAlertPresented = false

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            #if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            #endif
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                #endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
        .alert(Text("Update Required"), isPresented: $isUpdateAlertPresented) {
            Button {
                #if os(iOS)
                UIApplication.shared.open(
                    URL(string: "https://apps.apple.com/jp/app/id000000000")!
                )
                #endif
            } label: {
                Text("Open App Store")
            }
        } message: {
            Text("Please update Wishle to the latest version to continue using it.")
        }
        .task {
            isUpdateAlertPresented = (try? await CheckForUpdateIntent.perform()) ?? false
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
