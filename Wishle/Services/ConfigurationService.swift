import Foundation

@MainActor @Observable
final class ConfigurationService {
    static let shared = ConfigurationService()

    private(set) var configuration: Configuration?
    private let decoder = JSONDecoder()

    private init() {}

    func load() async throws {
        let url = URL(string: "https://raw.githubusercontent.com/muhiro12/Wishle/main/.config.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        configuration = try decoder.decode(Configuration.self, from: data)
    }

    func isUpdateRequired() -> Bool {
        guard let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
              let required = configuration?.requiredVersion,
              Bundle.main.bundleIdentifier?.contains("playgrounds") == false else {
            return false
        }
        return current.compare(required, options: .numeric) == .orderedAscending
    }
}
