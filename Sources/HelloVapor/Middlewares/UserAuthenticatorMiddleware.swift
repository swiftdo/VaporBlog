

import Vapor
import JWT
import Fluent

struct UserAuthenticatorMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        // 1. 从 Cookie 取 JWT
        if let token = request.cookies["access_token"]?.string {
            do {
                // 2. 验证 JWT（假设你用 JWTKit）
                let payload = try await request.jwt.verify(token, as: UserPayload.self)
                request.auth.login(payload)
            } catch {
                // 验证失败，跳过或拒绝
                // 也可以删除无效 cookie
                request.cookies["access_token"] = nil
            }
        }
        return try await next.respond(to: request)
    }
}
