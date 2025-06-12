
import Vapor
import Fluent

final class User: Model, Content, @unchecked Sendable {
    enum FieldKeys {
        static let id: FieldKey = "id"
        static let nickname: FieldKey = "nickname"
        static let isBanned: FieldKey = "is_banned"
        static let createdAt: FieldKey = "created_at"
        static let updatedAt: FieldKey = "updated_at"
    }

    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: FieldKeys.nickname)
    var nickname: String

    @Field(key: FieldKeys.isBanned)
    var isBanned: Bool // 表示用户是否被禁用（封禁）的状态标志

    @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?


    init() {}

    init(nickname: String, isBanned: Bool = false) {
        self.nickname = nickname
        self.isBanned = isBanned
    }
}
