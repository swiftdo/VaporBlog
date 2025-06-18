import Vapor
struct UserPageController: RouteCollection, @unchecked Sendable {


    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")

        let secure = users.grouped(UserAuthenticatorMiddleware())

        secure.get("profile", use: profile)

        // 必须登录
        // secure.group(":userId") { user in
        //     // 获取某个用户的信息
        //     user.get(use: show)
        // }
    }

    func profile(req: Request) async throws -> View {
        let userPayload = try req.auth.require(UserPayload.self)
        guard let user = try await User.find(userPayload.userId, on: req.db) else {
            throw APIError.notFound(msg: "用户不存在")
        }
        return try await req.view.render("user/profile", ["user": user])
    }
}