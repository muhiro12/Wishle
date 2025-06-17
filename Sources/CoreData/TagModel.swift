import Foundation
import SwiftData

@Model
final class TagModel {
    @Attribute(.unique) var id = UUID().uuidString
    private(set) var name: String

    init(name: String) {
        self.name = name
    }

    static func create(from tag: Tag, context: ModelContext) -> TagModel {
        let model = TagModel(name: tag.name)
        context.insert(model)
        return model
    }

    func asTag() -> Tag { .init(id: id, name: name) }
}
