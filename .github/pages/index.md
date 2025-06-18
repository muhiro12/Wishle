# Wishle Capabilities

This document summarizes the features currently implemented in the Wishle repository and highlights potential future capabilities.

## Current Features

- **Service-oriented architecture**: The codebase is organized into services such as `TaskService`, `RemindersImporter`, `RemindersExporter`, and `AISuggestionService`.
- **SwiftData storage**: Tasks (called wishes) and tags are persisted with SwiftData models (`WishModel`, `TagModel`).
- **CloudKit support**: When subscribed, the app stores data in CloudKit. Local storage is used otherwise.
- **App Intents integration**: Intents exist for adding, updating, and deleting wishes and tags, along with an intent to import Reminders. These are defined in `Sources/Intents`.
- **Reminders synchronization**: Importer and exporter services interact with `EventKit` to read from and write to Reminders.
- **On-device AI suggestions**: `AISuggestionService` generates suggestions using a foundation model with a prompt template stored in `Prompts/suggestion_template.txt`.
- **Widgets and Live Activities**:
  - `NextUpWidget` displays the next uncompleted task.
  - `WishleWidgetLiveActivity` and `NextUpLiveActivity` provide live activity support.
  - `WishleWidgetControl` demonstrates a control widget implementation.
- **Onboarding and Paywall**: `OnboardingFlow` guides new users, while `PaywallView` handles subscriptions via `SubscriptionManager`.
- **Unit tests**: Test targets cover key intents and services in `WishleTests`.

## Possible Extensions

- **Expanded Reminders syncing**: The groundwork for two-way Reminders integration suggests further automation or scheduling features could be added.
- **Additional widgets**: The existing widget infrastructure could host more widget types or complications.
- **Enhanced AI integration**: The AI suggestion service could be extended with more complex prompts or models to provide richer task recommendations.
- **Cross-platform support**: With SwiftUI and SwiftData, the project could adapt to macOS or visionOS with minimal changes.

