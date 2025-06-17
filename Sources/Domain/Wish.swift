import AppIntents
import Foundation

public struct Wish: AppEntity, Identifiable, Hashable {
    public let id: String
    public private(set) var title: String
    public private(set) var notes: String?
    public private(set) var createdAt: Date
    public private(set) var priority: Int

    public var displayRepresentation: DisplayRepresentation {
        .init(title: "\(title)")
    }

    static func make(title: String,
                     notes: String? = nil,
                     priority: Int = 0,
                     now: @autoclosure () -> Date = .init()) -> Wish {
        .init(id: UUID().uuidString,
              title: title,
              notes: notes,
              createdAt: now(),
              priority: priority)
    }
}
