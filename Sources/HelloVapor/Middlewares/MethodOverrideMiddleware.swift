import Vapor

struct MethodOverrideMiddleware: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        // 只对 POST 请求生效
        guard request.method == .POST else {
            return try await next.respond(to: request)
        }

        // 尝试解析表单中的 _method 字段
        if let methodOverride = try? request.content.get(String.self, at: "_method") {
            switch methodOverride.lowercased() {
            case "put": request.method = .PUT
            case "patch": request.method = .PATCH
            case "delete": request.method = .DELETE
            default: break
            }
        }

        return try await next.respond(to: request)
    }
    
    
}

