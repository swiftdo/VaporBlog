import Vapor
struct PostPageController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let posts = routes.grouped("posts")
        posts.get(use: indexPage)
        posts.get("create", use: createPage)
        posts.get(":id", use: showPage)
        posts.get(":id", "edit", use: editPage)
    }


    // 列表页
    func indexPage(req: Request) async throws -> View {
        let posts = try await Post.query(on: req.db).sort(\.$createdAt, .descending).all()
        return try await req.view.render("Posts/index", ["posts": posts])
    }

    // 创建页
    func createPage(req: Request) async throws -> View {
        return try await req.view.render("Posts/create")
    }

    // 详情页（可选）
    func showPage(req: Request) async throws -> View {
        guard let post = try await Post.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await req.view.render("Posts/show", ["post": post])
    }

    // 编辑页
    func editPage(req: Request) async throws -> View {
        guard let post = try await Post.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await req.view.render("Posts/edit", ["post": post])
    }
}