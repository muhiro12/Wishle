import Foundation

extension Locale {
    /// The identifier for the user's current device language.
    static var deviceLanguageIdentifier: String {
        current.language.languageCode?.identifier ?? current.identifier
    }
}

/// Utility for generating prompts that follow the user's device language.
enum PromptHelper {
    static func localized(_ text: String) -> String {
        "Respond in the user's device language: \(Locale.deviceLanguageIdentifier). \(text)"
    }
}

