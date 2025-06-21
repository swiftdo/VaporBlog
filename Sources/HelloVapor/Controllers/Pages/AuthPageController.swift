import Vapor
import Fluent
import ImperialGitHub

struct AuthPageController: RouteCollection, @unchecked Sendable {
    let authService: any AuthService

    init(authService: any AuthService) {
        self.authService = authService
    }

    func boot(routes: any RoutesBuilder) throws {
        
        let auth = routes.grouped("auth")

        let secure = auth.grouped(UserAuthenticatorMiddleware())

        auth.post("login", use: login)
        auth.get("activate", use: activate)
        auth.post("register", use: register)

        // 需要登录
        secure.post("logout", use: logout)

        try auth.oAuth(
            from: GitHub.self, 
            authenticate: "login-github", 
            callback: Environment.GITHUB_CALLBACK_URL(), 
            completion: processGitHubLogin
        )
    }

    private func processGitHubLogin(request: Request, token: String) async throws -> Response {
        let userInfo = try await GitHub.getUser(on: request)

        // 查找邮箱是否已注册
        let userAuth = try await UserAuth.query(on: request.db)
            .filter(\.$identifier == userInfo.login)
            .filter(\.$authType == UserAuth.AuthType.github.rawValue)
            .with(\.$user)
            .first()

        if let userAuth {
            // 直接登录
            if userAuth.user.status == User.Status.banned.rawValue {
                throw APIError.custom(code: 602, msg: "账号已被禁用，请联系管理员")
            }
            return try await githubLoginWithUser(userAuth.user, request: request)
        } else {
            // 注册， 默认激活状态
            let user = User(nickname: userInfo.name, status: .active)
            try await user.create(on: request.db) 
            let auth = try UserAuth(userID: user.requireID(), authType: UserAuth.AuthType.github, identifier: userInfo.login)
            try await auth.create(on: request.db)
            return try await githubLoginWithUser(user, request: request)
        }
    }

    private func githubLoginWithUser(_ user: User, request: Request) async throws -> Response { 
        let result = try await authService.generateAuthTokens(for: user, on: request.db, req: request)
            let response = request.redirect(to: "/page/posts/")
            // 设置 cookie
            setupCookie(result: result, response: response)
            return response
    }

    private func activate(req: Request) async throws -> Response {
        let input = try req.query.decode(InActive.self)
        try await authService.activate(input: input, request: req)
        try req.flash(.success, message: "激活成功")
        return req.redirect(to: "/page/posts/")
    }

    private func logout(req: Request) async throws -> Response {
        try await authService.logout(request: req)
        try req.flash(.success, message: "退出成功")
        let response = req.redirect(to: "/page/posts/")
        // 删除 cookie
        response.cookies["access_token"] = .expired
        response.cookies["refresh_token"] = .expired
        return response
    }

    private func register(req: Request) async throws -> Response {
        let input = try req.content.decode(InRegister.self)
        let result = try await req.db.transaction { db in
            return try await authService.register(input: input, activePath: "/page/auth/activate", db: db, request: req)
        }
        // 返回到首页
        try req.flash(.success, message: "注册成功，已发送邮件到您邮箱，请前往邮箱激活账号")
        let response = req.redirect(to: "/page/posts/")
        // 设置 cookie
        setupCookie(result: result, response: response)
        return response
    }

    private func login(req: Request) async throws -> Response {
        let inLogin = try req.content.decode(InLogin.self)
        let result = try await authService.login(input: inLogin, request: req)
        let response = req.redirect(to: "/page/posts/")
        // 设置 cookie
        setupCookie(result: result, response: response)
        return response
    }

    private func setupCookie(result: OutLogin, response: Response) {
        response.cookies["access_token"] = HTTPCookies.Value(
            string: result.token,
            expires: Date().addingTimeInterval(Environment.ACCESS_TOKEN_EXPIRE()),
            isSecure: true,
            isHTTPOnly: true,
        )

        response.cookies["refresh_token"] = HTTPCookies.Value(
            string: result.refreshToken,
            expires: Date().addingTimeInterval(Environment.REFRESH_TOKEN_EXPIRE()),
            isSecure: true,
            isHTTPOnly: true
        )
    } 

}

struct GithubUserInfo: Content {
    let name: String 
    let login: String // 是 GitHub 用户名（登录名），用于标识一个用户在 GitHub 上的唯一公开身份
    let email: String // 邮箱。


}

extension GitHub {
    static func getUser(on req: Request) async throws -> GithubUserInfo {
        var headers = HTTPHeaders()
        try headers.add(name: .authorization, value: "token \(req.accessToken)")
        headers.add(name: .userAgent, value: "Vapor")

        let response = try await req.client.get("https://api.github.com/user", headers: headers)

        guard response.status == .ok else {
            if response.status == .unauthorized {
                throw Abort.redirect(to: "/login-github")
            } else {
                throw Abort(.internalServerError)
            }
        }

        return try response.content.decode(GithubUserInfo.self)
    }

}