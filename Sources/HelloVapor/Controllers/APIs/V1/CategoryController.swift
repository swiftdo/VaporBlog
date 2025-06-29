import Vapor
import Fluent

struct CategoryController: RouteCollection {

    func boot(routes: any RoutesBuilder) throws {
        let categories = routes.grouped("categories")
        categories.get(use: index)
    }

    // 获取所有分类
    func index(req: Request) async throws -> APIResponse<[OutCategory]> {
        let categories = try await Category.query(on: req.db).all()
        let out = categories.map { OutCategory(from: $0) }
        return APIResponse(success: out) 
    }
}