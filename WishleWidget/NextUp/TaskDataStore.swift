import Foundation

struct TaskDataStore {
    static let shared = TaskDataStore()

    private let defaults = UserDefaults(suiteName: "group.com.muhiro12.wishle")
    private let key = "nextUpTask"

    func nextUpTask() -> WidgetTask? {
        guard let defaults, let data = defaults.data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(WidgetTask.self, from: data)
    }
}
