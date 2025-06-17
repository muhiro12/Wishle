import AppIntents
import Foundation

public struct Tag: AppEntity, Identifiable, Hashable {
    public let id: String
    public private(set) var name: String

    public var displayRepresentation: DisplayRepresentation {
        .init(title: "\(name)")
    }

    static func make(name: String) -> Tag {
        .init(id: UUID().uuidString, name: name)
    }
}
