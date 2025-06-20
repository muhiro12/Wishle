import Foundation
import SwiftData

@MainActor
struct SampleDataGenerator {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func generate() throws {
        let tagModels = Tag.sample().map(TagModel.init)
        for tag in tagModels {
            modelContext.insert(tag)
        }
        for index in 1...5 {
            let wish = WishModel(
                title: "Sample Wish \(index)",
                notes: "Sample note \(index)",
                dueDate: Calendar.current.date(byAdding: .day, value: index, to: .now),
                priority: index % 2,
                tags: [tagModels[index % tagModels.count]]
            )
            modelContext.insert(wish)
        }
        try modelContext.save()
    }

    func removeAll() throws {
        let wishes = try modelContext.fetch(FetchDescriptor<WishModel>())
        for wish in wishes {
            modelContext.delete(wish)
        }
        let tags = try modelContext.fetch(FetchDescriptor<TagModel>())
        for tag in tags {
            modelContext.delete(tag)
        }
        try modelContext.save()
    }
}
