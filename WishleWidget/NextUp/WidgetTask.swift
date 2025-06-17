import Foundation

struct WidgetTask: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var dueDate: Date?
    var priority: Int
}

extension WidgetTask {
    static var placeholder: WidgetTask {
        .init(id: .init(), title: "Sample", dueDate: .now.addingTimeInterval(3_600), priority: 0)
    }
}
