import Fluent
import Vapor 

// 用于更新 token
final class RefreshToken: Model, Content, @unchecked Sendable {
    enum FieldKeys {
        static let id: FieldKey = "id"
        static let token: FieldKey = "token"
        static let userId: FieldKey = "user_id"
        static let expiresAt: FieldKey = "expires_at"
        static let createdAt: FieldKey = "created_at"
    }

    static let schema = "refresh_tokens"

    @ID(key:.id)
    var id: UUID?

    @Field(key: FieldKeys.token)
    var token: String

    @Parent(key: FieldKeys.userId)
    var user: User

    @Field(key: FieldKeys.expiresAt)
    var expiresAt: Date

    @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?

    init() {}

    init(token: String, userID: UUID, expiresAt: Date) {
        self.token = token
        self.$user.id = userID
        self.expiresAt = expiresAt
    }
}
