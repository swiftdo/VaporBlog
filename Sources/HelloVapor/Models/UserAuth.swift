import Fluent
import Vapor

// MARK: - UserAuth (登录方式表)
final class UserAuth: Model, Content, @unchecked Sendable {

    static let schema = "user_auths"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: FieldKeys.userId)
    var user: User

    @Field(key: FieldKeys.authType)
    var authType: String

    @Field(key: FieldKeys.identifier)
    var identifier: String  // 登录标识，比如邮箱或微信的 OpenID

    @OptionalField(key: FieldKeys.credential)
    var credential: String?  // 令牌, 比如密码

    @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?

    init() {}

    init(userID: UUID, authType: AuthType, identifier: String, credential: String? = nil) {
        self.$user.id = userID
        self.authType = authType.rawValue
        self.identifier = identifier
        self.credential = credential
    }
}

extension UserAuth {
    enum FieldKeys {
        static let id: FieldKey = "id"
        static let userId: FieldKey = "user_id"
        static let authType: FieldKey = "auth_type"
        static let identifier: FieldKey = "identifier"
        static let credential: FieldKey = "credential"
        static let createdAt: FieldKey = "created_at"
    }

    enum AuthType: String, Codable {
        case email = "email"  // 邮箱登录
        case google = "google"  // google 登录
        case github = "github" // github 登录
    }

}
