# Wishle

Wishle is a lightweight task manager that focuses on what you **wish** to accomplish rather than what you **must** do. The app is built entirely in SwiftUI and uses SwiftData with CloudKit to keep your data in sync across devices.

## Features

- Service-oriented architecture for easy maintainability
- SwiftData storage with optional iCloud sync
- Widgets including "Next Up" to highlight your upcoming task
- Foundation model integration for on-device suggestions

## Requirements

- Xcode 16 or later
- iOS 18.0 or later

## Building

1. Clone this repository.
2. Open `Wishle.xcodeproj` in Xcode.
3. Select the **Wishle** scheme and run the app with **⌘R**.

## Testing

The test targets currently contain placeholders. To run the available tests in Xcode, select **Product → Test** or press **⌘U**.

## Project Structure

- `Wishle/` – Main application source files
- `WishleWidget/` – Widget and Live Activity extensions
- `WishleTests/` – Unit tests
- `WishleUITests/` – UI tests

For additional project guidelines, see `AGENTS.md`.

