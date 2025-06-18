import Vapor
import Fluent

final class AuthServiceImpl: AuthService {

    func logout(request: Request) async throws {
        let userPayload = try request.auth.require(UserPayload.self)

        // 删除刷新 token
        try await RefreshToken.query(on: request.db)
            .filter(\.$user.$id == userPayload.userId)
            .delete()
    }

    func refreshToken(input: InRefreshToken, request: Request) async throws -> OutLogin {
        let input = try request.content.decode(InRefreshToken.self)

        guard
            let refreshToken = try await RefreshToken.query(on: request.db)
                .with(\.$user)
                .filter(\.$token == input.refreshToken)
                .first()
        else {
            throw APIError.notFound(msg: "无效的刷新令牌")
        }

        if refreshToken.expiresAt < Date() {
            try await refreshToken.delete(on: request.db)
            throw APIError.custom(code: 600, msg: "刷新令牌已过期")
        }

        // 获取用户
        let user = refreshToken.user 

        if user.status != User.Status.active.rawValue {
            // 清除所有该用户的刷新令牌
            try await RefreshToken.query(on: request.db)
                .filter(\.$user.$id == user.requireID())
                .delete()
            throw APIError.custom(code: 601, msg: "用户状态非激活状态，不允许修改")
        }

        // 删除旧的 refresh token
        try await refreshToken.delete(on: request.db)
        return try await generateAuthTokens(for: user, on: request.db, req: request)
    }

    func login(input: InLogin, request: Request) async throws -> OutLogin {
        guard
            let auth = try await UserAuth.query(on: request.db)
                .filter(\.$authType == UserAuth.AuthType.email.rawValue)
                .filter(\.$identifier == input.email)
                .first(),
            let user = try await User.find(auth.$user.id, on: request.db)
        else {
            throw APIError.custom(code: 600, msg: "账号或密码错误")
        }

        // 检查用户是否被禁用
        if user.status == User.Status.banned.rawValue {
            throw APIError.custom(code: 602, msg: "账号已被禁用，请联系管理员")
        }

        // 验证密码
        guard let credential = auth.credential,
            try Bcrypt.verify(input.password, created: credential)
        else {
            throw APIError.custom(code: 603, msg: "账号或密码错误")
        }
        return try await generateAuthTokens(for: user, on: request.db, req: request)
    }

    func register(input: InRegister, db: any Database, request: Request) async throws -> OutLogin {
        let userAuth = try await UserAuth.query(on: db)
            .filter(\.$authType == UserAuth.AuthType.email.rawValue)
            .filter(\.$identifier == input.email)
            .first()

        if userAuth != nil {
            throw APIError.alreadyExists(msg: "邮箱已被注册")
        }

        // 创建用户
        let user = User(nickname: input.email)
        try await user.create(on: db)

        // 创建认证记录
        let auth = UserAuth(
            userID: try user.requireID(),
            authType: .email,
            identifier: input.email,
            credential: try Bcrypt.hash(input.password)
        )
        try await auth.create(on: db)

        // 生成激活码
        try await sendActiveEmail(userId: user.requireID(), email: input.email, db: db, req: request)
        // 创建 token
        return try await generateAuthTokens(for: user, on: db, req: request)
    }

    // 生成认证令牌
    private func generateAuthTokens(for user: User, on db: any Database, req: Request) async throws
        -> OutLogin
    {
        let payload = UserPayload(userId: try user.requireID())
        let token = try await req.jwt.sign(payload)

        let refreshToken = RefreshToken(
            token: [UInt8].random(count: 32).base64,
            userID: try user.requireID(),
            expiresAt: Date().addingTimeInterval(3600 * 24 * 30)
        )
        try await refreshToken.create(on: db)
        return OutLogin(
            token: token,
            refreshToken: refreshToken.token,
            user: OutUser(user: user)
        )
    }

    private func sendActiveEmail(userId: UUID, email:String, db: any Database, req: Request) async throws -> Void {
        let code = generateActivationCode(userId: userId, email: email)
        let expiredAt = Date().addingTimeInterval(30 * 60)  // 30分钟有效
        let verify =  EmailVerifyCode(
            email: email, 
            code: code, 
            type: EmailVerifyCode.VerifyType.activation,
            expiredAt: expiredAt
        )
        try await verify.create(on: db)

        
        let link = (Environment.get("SITE_DOMAIN") ?? "http://localhost:8080") + "/api/v1/auth/activate?token=\(code)"
        // 发送邮件
        let html = """
        <html>
        <body>
            请点击此链接激活：<a href='\(link)'>\(link)</a>
        </body>
        </html>
        """
        try await req.sendEmail(subject: "【VaporBlog】 账号激活", body: html, to: email, isBodyHtml: true)
    }

    func generateActivationCode(userId: UUID, email: String) -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let raw = "\(userId.uuidString)|\(email)|\(timestamp)"
        let digest = Insecure.MD5.hash(data: raw.data(using: .utf8)!)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}