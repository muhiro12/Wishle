import AppIntents
import Foundation
import SwiftData
import SwiftUtilities

public struct Wish: AppEntity {
    public static var defaultQuery = WishQuery()

    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Wish")
    }

    public var displayRepresentation: DisplayRepresentation {
        .init(title: "\(title)")
    }

    public var id: String
    public var title: String
    public var notes: String?
    public var createdAt: Date
    public var priority: Int

    init(id: String, title: String, notes: String? = nil, createdAt: Date, priority: Int) {
        self.id = id
        self.title = title
        self.notes = notes
        self.createdAt = createdAt
        self.priority = priority
    }

    static func make(title: String,
                     notes: String? = nil,
                     priority: Int = 0,
                     now: @autoclosure () -> Date = .init()) -> Self {
        .init(id: UUID().uuidString,
              title: title,
              notes: notes,
              createdAt: now(),
              priority: priority)
    }
}

extension Wish: ModelBridgeable {
    public typealias Model = WishModel

    public init?(_ model: WishModel) {
        guard let encodedID = try? model.id.base64Encoded() else {
            return nil
        }
        let entity = Wish(
            id: encodedID,
            title: model.title,
            notes: model.notes,
            createdAt: model.createdAt,
            priority: model.priority
        )
        self = entity
    }
}
