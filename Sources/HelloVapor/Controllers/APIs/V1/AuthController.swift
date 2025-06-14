import Fluent
import Vapor
import Smtp

struct AuthController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {

        // 这个路由名符合 restful api 规范么？
        let authRoutes = routes.grouped("auth")
        authRoutes.post("register", use: register)
        authRoutes.post("login", use: login)
        // authRoutes.post("resetpwd", use: resetPwd)
        // 账号激活
        authRoutes.get("activate", use: activate)

        // 需要登录才能进行访问
        // 重新发送激活邮件
        //authRoutes.post("resend", use: resend)
        // authRoutes.post("logout", use: logout)
        // authRoutes.post("refresh", use: refresh)
        // authRoutes.post("changepwd", use: changePwd)

    }

    // 用户注册
    func register(req: Request) async throws -> APIResponse<OutLogin> {
        let input = try req.content.decode(InRegister.self)

        return try await req.db.transaction { db in
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
            let code = try generateActivationCode(userId: user.requireID(), email: input.email)
            let expiredAt = Date().addingTimeInterval(30 * 60)  // 30分钟有效
            let verify =  EmailVerifyCode(
                email: input.email, 
                code: code, 
                type: EmailVerifyCode.VerifyType.activation,
                expiredAt: expiredAt
            )
            try await verify.create(on: db)

            

            let link = Environment.get("SITE_DOMAIN") ?? "http://localhost:8080" + "/api/v1/auth/activate?token=\(code)"

            // 发送邮件
            let html = """
            <html>
            <body>
                请点击此链接激活：<a href='\(link)'>\(link)</a>
            </body>
            </html>
            """
            let email = try Email(
                from: EmailAddress(address: "13576051334@163.com"),
                to: [EmailAddress(address: input.email)],
                subject: "【VaporBlog】 账号激活",
                body: html, 
                isBodyHtml: true)
            
            try await req.smtp.send(email)

            // 创建 token
            let result = try await generateAuthTokens(for: user, on: db, req: req)
            return APIResponse(success: result)
        }
    }

    // 用户登录
    func login(req: Request) async throws -> APIResponse<OutLogin> {
        let input = try req.content.decode(InLogin.self)
        // 查找认证记录
        guard
            let auth = try await UserAuth.query(on: req.db)
                .filter(\.$authType == UserAuth.AuthType.email.rawValue)
                .filter(\.$identifier == input.email)
                .first(),
            let user = try await User.find(auth.$user.id, on: req.db)
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
        let result = try await generateAuthTokens(for: user, on: req.db, req: req)
        return APIResponse(success: result)
    }

    // 生成验证邮件的 token
    func activate(req: Request) async throws -> APIResponse<OutEmpty> {
        let input = try req.query.decode(InActive.self)
        // 校验激活码
        guard
            let verify = try await EmailVerifyCode.query(on: req.db)
                .filter(\.$code == input.token)
                .filter(\.$type == EmailVerifyCode.VerifyType.activation.rawValue)
                .filter(\.$expiredAt > Date())
                .first()
        else {
            throw APIError.custom(code: 601, msg: "激活码无效或已过期")
        }

        guard let userAuth = try await UserAuth.query(on: req.db)
            .filter(\.$identifier == verify.email)
            .filter(\.$authType == UserAuth.AuthType.email.rawValue)
            .with(\.$user)
            .first() else {
                throw APIError.custom(code: 602, msg: "用户不存在")
        }
        
        guard userAuth.user.status == User.Status.inactive.rawValue else  {
            throw APIError.custom(code: 603, msg: "用户已激活")
        }

        // 设置为激活状态
        userAuth.user.status = User.Status.active.rawValue
        try await userAuth.user.save(on: req.db)
        try await verify.delete(on: req.db)
        return APIResponse(success: OutEmpty())
    }


    /// 生成激活码：用户id + 邮箱 + 时间戳，md5
    func generateActivationCode(userId: UUID, email: String) -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let raw = "\(userId.uuidString)|\(email)|\(timestamp)"
        let digest = Insecure.MD5.hash(data: raw.data(using: .utf8)!)
        return digest.map { String(format: "%02hhx", $0) }.joined()
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
}
