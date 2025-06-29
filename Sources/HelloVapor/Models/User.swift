
import Vapor
import Fluent

final class User: Model, Content, @unchecked Sendable {
    enum FieldKeys {
        static let id: FieldKey = "id"
        static let nickname: FieldKey = "nickname"
        static let status: FieldKey = "status"
        static let createdAt: FieldKey = "created_at"
        static let updatedAt: FieldKey = "updated_at"
    }

    enum Status: Int {
        case inactive = 0 // 未激活
        case active = 1   // 激活，正常状态
        case banned = 2   // 封禁
        case deleted = 3  // 删除状态
    }

    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: FieldKeys.nickname)
    var nickname: String

    @Field(key: FieldKeys.status)
    var status: Int

    @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?


    // 与 Posts 的关系：一个用户可以有多篇文章
    @Children(for: \.$author)
    var posts: [Post]


    init() {}

    init(nickname: String, status: Status = .inactive) {
        self.nickname = nickname
        self.status = status.rawValue
    }
}
