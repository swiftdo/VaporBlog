import Vapor 

struct OutUser: Out {
    let id: UUID?
    let nickname: String

    init(user: User) {
        self.id = user.id
        self.nickname = user.nickname
    }
}