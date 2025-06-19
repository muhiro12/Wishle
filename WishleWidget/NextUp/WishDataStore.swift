import Foundation

struct WishDataStore {
    static let shared = Self()

    private let defaults = UserDefaults(suiteName: "group.com.muhiro12.wishle")
    private let key = "nextUpWish"

    func nextUpWish() -> WidgetWish? {
        guard let defaults, let data = defaults.data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(WidgetWish.self, from: data)
    }
}
