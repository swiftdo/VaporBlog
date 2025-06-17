import Vapor
struct AuthPageController: RouteCollection, @unchecked Sendable {
    let authService: any AuthService

    init(authService: any AuthService) {
        self.authService = authService
    }

    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("auth")

        auth.post("login", use: login)
        auth.post("register", use: register)
    }

    private func register(req: Request) async throws -> Response {
        let input = try req.content.decode(InRegister.self)
        let result = try await req.db.transaction { db in
            return try await authService.register(input: input, db: db, request: req)
        }
        // 设置 cookie
        setupCookie(result: result, req: req)
        // 返回到首页
        return req.redirect(to: "/page/posts/")
    }

    private func login(req: Request) async throws -> Response {
        let inLogin = try req.content.decode(InLogin.self)
        let result = try await authService.login(input: inLogin, request: req)
        // 设置 cookie
        setupCookie(result: result, req: req)
        // 返回到首页
        return req.redirect(to: "/page/posts/")
    }

    private func setupCookie(result: OutLogin, req: Request) {
        req.cookies["access_token"] = HTTPCookies.Value(
            string: result.token,
            expires: Date().addingTimeInterval(3600),
            isSecure: true,
            isHTTPOnly: true
        )

        req.cookies["refresh_token"] = HTTPCookies.Value(
            string: result.refreshToken,
            expires: Date().addingTimeInterval(3600),
            isSecure: true,
            isHTTPOnly: true
        )
    } 

}