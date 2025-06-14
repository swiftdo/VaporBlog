import Fluent
import Vapor
// 邮箱验证码
final class EmailVerifyCode: Model, Content, @unchecked Sendable {
    static let schema = "email_verify_codes"

    @ID(key: .id)
    var id: UUID?

    @Field(key: FieldKeys.email)
    var email: String
    
    @Field(key: FieldKeys.code)
    var code: String 

    @Field(key: FieldKeys.type)
    var type: String

    @Field(key: FieldKeys.expiredAt)
    var expiredAt: Date

     @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?

    /// 更新时间戳，`on: .update` 表示在更新记录时自动设置。
    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?

    init() {}

    init(email: String, code: String, type: VerifyType, expiredAt: Date) {
        self.email = email
        self.code = code
        self.type = type.rawValue
        self.expiredAt = expiredAt
    }

    enum FieldKeys {
        static let email: FieldKey = "email"
        static let code: FieldKey = "code"
        static let type: FieldKey = "type"
        static let expiredAt: FieldKey = "expired_at"
        static let createdAt: FieldKey = "created_at"
        static let updatedAt: FieldKey = "updated_at"
    }

    enum VerifyType: String {
        case activation // 激活
        case resetPassword // 重置密码
    }
}