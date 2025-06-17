import Vapor

struct UserController: RouteCollection {

    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        let secure = users.grouped(UserPayload.authenticator(), UserPayload.guardMiddleware())

        // 必须登录
        secure.group(":userId") { user in
            // 获取某个用户的信息
            user.get(use: show)
        }
    }
    
    // 获取到用户信息
    private func show(req: Request) async throws -> APIResponse<OutUser> {
       guard let user = try await User.find(req.parameters.get("userId"), on: req.db) else {
            throw APIError.notFound(msg: "用户未找到")
       }
       return .init(success: OutUser(user: user))
    }
}