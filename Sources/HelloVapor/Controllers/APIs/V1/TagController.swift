import Vapor
import Fluent

struct TagController: RouteCollection {

    func boot(routes: any RoutesBuilder) throws {
        let tags = routes.grouped("tags")
        
        // 获取所有标签
        tags.get(use: index)
    }

    // 获取所有标签
    func index(req: Request) async throws -> APIResponse<[OutTag]> {
        let tags = try await Tag.query(on: req.db).all()
        let out = tags.map { OutTag(from: $0) }
        return APIResponse(success: out)    
    }
}