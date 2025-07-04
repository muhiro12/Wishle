import Foundation
import SwiftData

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

        let wishes: [(String, String?, Int, [TagModel])] = [
            (
                "Plan a weekend trip to the mountains",
                "Look up cabin rentals and hiking trails",
                1,
                [tagModels[0], tagModels[2]]
            ),
            (
                "Try a new recipe for chocolate cake",
                "Gather all ingredients and preheat the oven",
                0,
                [tagModels[1]]
            ),
            (
                "Organize a board game night with friends",
                "Create a chat group and pick a date",
                0,
                [tagModels[2]]
            ),
            (
                "Start a small herb garden on the balcony",
                "Buy seeds and planters for basil and mint",
                1,
                [tagModels[3], tagModels[2]]
            ),
            (
                "Write a short story about a time traveler",
                "Outline characters and key plot points",
                0,
                [tagModels[3]]
            )
        ]

        for (offset, item) in wishes.enumerated() {
            let wish = WishModel(
                title: item.0,
                notes: item.1,
                dueDate: Calendar.current.date(byAdding: .day, value: (offset + 1) * 3, to: .now),
                priority: item.2,
                tags: item.3
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
