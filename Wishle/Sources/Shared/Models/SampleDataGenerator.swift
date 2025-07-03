import Foundation
import SwiftData

@MainActor
struct SampleDataGenerator {
    private let modelContainer: ModelContainer

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }

    func generate() throws {
        let tagModels = Tag.sample().map(TagModel.init)
        for tag in tagModels {
            modelContainer.mainContext.insert(tag)
        }
        for index in 1...5 {
            let wish = WishModel(
                title: "Sample Wish \(index)",
                notes: "Sample note \(index)",
                dueDate: Calendar.current.date(byAdding: .day, value: index, to: .now),
                priority: index % 2,
                tags: [tagModels[index % tagModels.count]]
            )
            modelContainer.mainContext.insert(wish)
        }
        try modelContainer.mainContext.save()
    }

    func removeAll() throws {
        let wishes = try modelContainer.mainContext.fetch(FetchDescriptor<WishModel>())
        for wish in wishes {
            modelContainer.mainContext.delete(wish)
        }
        let tags = try modelContainer.mainContext.fetch(FetchDescriptor<TagModel>())
        for tag in tags {
            modelContainer.mainContext.delete(tag)
        }
        try modelContainer.mainContext.save()
    }
}
