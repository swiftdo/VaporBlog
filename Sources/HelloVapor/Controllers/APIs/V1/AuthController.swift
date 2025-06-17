import Fluent
import Vapor

struct AuthController: RouteCollection, @unchecked Sendable {

    let authService: any AuthService

    init(authService: any AuthService) {
        self.authService = authService
    }

    func boot(routes: any RoutesBuilder) throws {

        // 这个路由名符合 restful api 规范么？
        let authRoutes = routes.grouped("auth")
        authRoutes.post("register", use: register)
        authRoutes.post("login", use: login)
        authRoutes.post("refreshToken", use: refreshToken)
        authRoutes.post("resetpwd", use: resetPwd)
        // 账号激活
        authRoutes.get("activate", use: activate)
        // 获取重置密码验证码
        authRoutes.post("resetpwd", "code", use: sendResetPwdCode)


        // 需要登录才能进行访问
        let secure = authRoutes.grouped(UserPayload.authenticator(), UserPayload.guardMiddleware())
        secure.get("me", use: me)

        secure.post("logout", use: logout)
        // 重新发送激活邮件
        secure.post("resend", use: resend)
        // authRoutes.post("logout", use: logout)
        // authRoutes.post("refresh", use: refresh)
        secure.post("changepwd", use: changePwd)

    }

    func resetPwd(req: Request) async throws -> APIResponse<OutEmpty> { 
        let input = try req.content.decode(InResetPwd.self)

        guard let userAuth = try await UserAuth.query(on: req.db)
            .filter(\.$identifier == input.email)
            .filter(\.$authType == UserAuth.AuthType.email.rawValue)
            .first()
        else {
            throw APIError.notFound(msg: "用户不存在")
        }

        // 找到邮件对应的验证码
        let allCodes = try await EmailVerifyCode.query(on: req.db)
            .filter(\.$email == input.email)
            .filter(\.$type == EmailVerifyCode.VerifyType.resetPassword.rawValue)
            .filter(\.$code == input.code)
            .all()

        let index = allCodes.firstIndex { verifyCode in
            return verifyCode.expiredAt > Date() && verifyCode.code == input.code
        }

        guard let index = index , index >= 0 else {
            throw APIError.notFound(msg: "验证码错误")
        }

        let verifyCode = allCodes[index]
        userAuth.credential = try Bcrypt.hash(input.newPwd)

        // 开启事务
        try await req.db.transaction { db in
            try await userAuth.save(on: db)
            try await verifyCode.delete(on: db)
        }
        return APIResponse(data: OutEmpty())
    }


    func sendResetPwdCode(req: Request) async throws -> APIResponse<OutEmpty> { 
        let input = try req.content.decode(InResetPwdCode.self)
        // 发送邮件
        guard let userAuth = try await UserAuth.query(on: req.db)
            .filter(\.$identifier == input.email)
            .filter(\.$authType == UserAuth.AuthType.email.rawValue)
            .first()
        else {
            throw APIError.notFound(msg: "用户不存在")
        }

        // 生成验证码，6 位
        let code = String(Int.random(in: 100000...999999))
        let email = userAuth.identifier

        let expiredAt = Date().addingTimeInterval(30 * 60)  // 30分钟有效
        let verifyCode = EmailVerifyCode(email: email, code: code, type: EmailVerifyCode.VerifyType.resetPassword, expiredAt: expiredAt)
        try await verifyCode.save(on: req.db)


        // 发送邮件
        let html = """
        <html>
        <body>
            重置密码的验证码：\(code)
        </body>
        </html>
        """
        try await req.sendEmail(subject: "【VaporBlog】 重置密码", body: html, to: email, isBodyHtml: true)
        return .init(success: OutEmpty())
    }



    func changePwd(req: Request) async throws -> APIResponse<OutEmpty> { 
        let userPayload = try req.auth.require(UserPayload.self)
        guard let user = try await User.find(userPayload.userId, on: req.db) else {
            throw APIError.notFound(msg: "用户不存在")
        }

        let inChangePwd = try req.content.decode(InChangePwd.self)

        // 判断新旧密码是否一致
        guard let userAuth = try await UserAuth.query(on: req.db)
            .filter(\.$user.$id == user.requireID())
            .filter(\.$authType == UserAuth.AuthType.email.rawValue)
            .first()
        else {
            throw APIError.notFound(msg: "用户不存在")
        }

        guard let credential = userAuth.credential,
            try Bcrypt.verify(inChangePwd.oldPwd, created: credential)
        else {
            throw APIError.custom(code: 603, msg: "账号或密码错误")
        }
        userAuth.credential = try Bcrypt.hash(inChangePwd.newPwd)
        try await userAuth.save(on: req.db)
        return APIResponse(success: OutEmpty())
    }

    func resend(req: Request) async throws -> APIResponse<OutEmpty> {
        let userPayload = try req.auth.require(UserPayload.self)
        guard let user = try await User.find(userPayload.userId, on: req.db) else {
            throw APIError.notFound(msg: "用户不存在")
        }
        guard user.status == User.Status.inactive.rawValue else {
            throw APIError.custom(code: 600, msg: "用户已激活，无需发送")
        }
        // TODO: 控制发送频次，可自行实现
        // 删除这个用户已发送的激活码 
        guard let userAuth = try await UserAuth.query(on: req.db)
            .filter(\.$user.$id == user.requireID())
            .filter(\.$authType == UserAuth.AuthType.email.rawValue)
            .first()
        else {
            throw APIError.notFound(msg: "用户不存在")
        }
        // 发送邮件
        try await sendActiveEmail(userId: user.requireID(), email: userAuth.identifier, db: req.db, req: req)
        return APIResponse(success: OutEmpty())
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

    func refreshToken(req: Request) async throws -> APIResponse<OutLogin> { 
        let input = try req.content.decode(InRefreshToken.self)
        let result = try await authService.refreshToken(input: input, request: req)
        return APIResponse(success: result)
    }


    func logout(req: Request) async throws -> APIResponse<OutEmpty> {
        let userPayload = try req.auth.require(UserPayload.self)

        // 删除刷新 token
        try await RefreshToken.query(on: req.db)
            .filter(\.$user.$id == userPayload.userId)
            .delete()
        return APIResponse(success: OutEmpty())
    }

    func me(req: Request) async throws -> APIResponse<OutUser> {
        let userPayload = try req.auth.require(UserPayload.self)
        guard let user = try await User.find(userPayload.userId, on: req.db) else {
            throw APIError.notFound(msg: "用户不存在")
        }
        return APIResponse(success: OutUser(user: user))
    }

    // 用户注册
    func register(req: Request) async throws -> APIResponse<OutLogin> {
        let input = try req.content.decode(InRegister.self)
        return try await req.db.transaction { db in
            // 创建 token
            let result = try await authService.register(input: input, db: db, request: req)
            return APIResponse(success: result)
        }
    }

    // 用户登录
    func login(req: Request) async throws -> APIResponse<OutLogin> {
        let input = try req.content.decode(InLogin.self)
        let result = try await authService.login(input: input, request: req);
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

        try await req.db.transaction { db in
            try await userAuth.user.save(on: db)
            try await verify.delete(on: db)
        }
        return APIResponse(success: OutEmpty())
    }


    /// 生成激活码：用户id + 邮箱 + 时间戳，md5
    func generateActivationCode(userId: UUID, email: String) -> String {
        let timestamp = Int(Date().timeIntervalSince1970)
        let raw = "\(userId.uuidString)|\(email)|\(timestamp)"
        let digest = Insecure.MD5.hash(data: raw.data(using: .utf8)!)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}


