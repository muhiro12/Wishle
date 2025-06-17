import Foundation
import SwiftData

@Model
final class WishModel {
    @Attribute(.unique) var id = UUID().uuidString
    private(set) var title: String
    private(set) var notes: String?
    private(set) var createdAt: Date
    private(set) var priority: Int

    init(title: String,
         notes: String? = nil,
         createdAt: Date = .init(),
         priority: Int = 0) {
        self.title = title
        self.notes = notes
        self.createdAt = createdAt
        self.priority = priority
    }

    static func create(from wish: Wish,
                       context: ModelContext) -> WishModel {
        let model = WishModel(title: wish.title,
                              notes: wish.notes,
                              createdAt: wish.createdAt,
                              priority: wish.priority)
        context.insert(model)
        return model
    }

    func asWish() -> Wish { .init(id: id,
                                  title: title,
                                  notes: notes,
                                  createdAt: createdAt,
                                  priority: priority) }
}
