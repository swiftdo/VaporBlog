import Vapor

struct OutCategory: Out {
    let id: UUID
    let name: String

    init(from category: Category) {
        self.id = category.id!
        self.name = category.name
    }
}