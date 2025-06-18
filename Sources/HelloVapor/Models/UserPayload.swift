import JWT
import Vapor 

// MARK: - JWT Payload, 通过遵循 Authenticatable 协议和 JWTPayload 协议，你可以使用 authator() 方法生成一个路由认证器
struct UserPayload: Authenticatable, JWTPayload {

    // 标准声明
    var exp: ExpirationClaim // 过期时间
    var sub: SubjectClaim  // 存储userID

    var userId: UUID // 用户Id

    // 初始化方法
    init(userId: UUID) {
        let expiration: TimeInterval = Environment.ACCESS_TOKEN_EXPIRE() // 默认24小时有效期
        self.exp = .init(value: Date().addingTimeInterval(expiration))
        self.sub = .init(value: userId.uuidString)
        self.userId = userId
    }
    
    func verify(using algorithm: some JWTAlgorithm) async throws {
        try exp.verifyNotExpired()
    }
}
