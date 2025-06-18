import AppIntents
import Foundation

public struct Tag: AppEntity, Identifiable, Hashable {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Tag")
    }

    public static var defaultQuery = TagQuery()

    public let id: String
    public private(set) var name: String

    public var displayRepresentation: DisplayRepresentation {
        .init(title: "\(name)")
    }

    static func make(name: String) -> Self {
        .init(id: UUID().uuidString, name: name)
    }
}
