import Vapor 

struct OutTag: Out {
    let id: UUID
    let name: String

    init(from tag: Tag) {
        self.id = tag.id!
        self.name = tag.name
    }
}