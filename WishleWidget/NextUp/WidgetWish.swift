import Foundation

struct WidgetWish: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var dueDate: Date?
    var priority: Int
}

extension WidgetWish {
    static var placeholder: WidgetWish {
        .init(id: .init(), title: "Weekend trip", dueDate: .now.addingTimeInterval(3_600), priority: 0)
    }
}
