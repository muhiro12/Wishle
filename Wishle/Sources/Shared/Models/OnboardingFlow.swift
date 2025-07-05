//
//  OnboardingFlow.swift
//  Wishle
//
//  Created by Codex on 2025/06/18.
//

import SwiftUI
import TipKit

nonisolated struct SwipeToCompleteTip: Tip {
    var title: Text {
        Text("Swipe to complete")
    }
    var message: Text? {
        Text("Swipe a wish to mark it completed.")
    }
}

nonisolated struct LongPressQuickEditTip: Tip {
    var title: Text {
        Text("Long-press for quick edit")
    }
    var message: Text? {
        Text("Long press on a wish to edit it.")
    }
}

struct OnboardingFlow: View {
    @State private var selection = 0
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    private let swipeTip: SwipeToCompleteTip = .init()
    private let editTip: LongPressQuickEditTip = .init()

    var body: some View {
        TabView(selection: $selection) {
            page(
                title: String(localized: "Welcome to Wishle"),
                description: String(
                    localized: "Store what you wish to do, not what you must do."
                )
            ) {
                Button("Next") {
                    selection = 1
                }
            }
            .tag(0)

            page(title: nil, description: nil) {
                TipView(swipeTip)
                Button("Next") {
                    selection = 2
                }
            }
            .tag(1)

            page(title: nil, description: nil) {
                TipView(editTip)
                Button("Get Started") {
                    finish()
                }
            }
            .tag(2)
        }
        .tabViewStyle(.page)
    }

    private func page(title: String?, description: String?, @ViewBuilder content: () -> some View) -> some View {
        VStack(spacing: 20) {
            Spacer()
            if let title {
                Text(title)
                    .font(.largeTitle)
            }
            if let description {
                Text(description)
            }
            content()
            Spacer()
        }
        .padding()
    }

    private func finish() {
        hasSeenOnboarding = true
    }
}

#Preview {
    OnboardingFlow()
}
