import AppIntents
import Foundation

struct CheckForUpdateIntent: AppIntent, IntentPerformer {
    typealias Output = Bool

    nonisolated static let title: LocalizedStringResource = "Check for Update"

    static func perform() async throws -> Bool {
        let url = URL(string: "https://raw.githubusercontent.com/muhiro12/Wishle/main/.config.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let configuration = try JSONDecoder().decode(Configuration.self, from: data)
        guard let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              Bundle.main.bundleIdentifier?.contains("playgrounds") == false else {
            return false
        }
        return current.compare(configuration.requiredVersion, options: .numeric) == .orderedAscending
    }

    func perform() async throws -> some ReturnsValue<Bool> {
        .result(value: try await Self.perform())
    }
}
