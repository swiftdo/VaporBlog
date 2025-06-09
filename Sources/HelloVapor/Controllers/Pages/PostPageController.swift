import Vapor
struct PostPageController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let posts = routes.grouped("posts")
        
        // GET 请求：页面展示
        posts.get(use: indexPage)                // 列表页面
        posts.get("create", use: createPage)     // 创建页面
        posts.get(":id", use: showPage)          // 详情页面
        posts.get(":id", "edit", use: editPage)  // 编辑页面
        
        
        // 数据操作
        posts.post(use: storeAction)             // 创建资源
        posts.post(":id", "update", use: updateAction)     // 更新资源, 因为表单不支持 put
        posts.post(":id", "delete", use: deleteAction)   // 删除资源, 因为表单不支持 delete
    }
    
    // 保存新文章
    func storeAction(req: Request) async throws -> Response {
        let post = try req.content.decode(Post.self)
        try await post.save(on: req.db)
        return req.redirect(to: "/page/posts")
    }

    // 更新文章
    func updateAction(req: Request) async throws -> Response {
        guard let post = try await Post.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        let input = try req.content.decode(InPost.self)
        post.title = input.title
        post.content = input.content
        try await post.save(on: req.db)
        return req.redirect(to: "/page/posts")
    }

    // 删除文章
    func deleteAction(req: Request) async throws -> Response {
        guard let post = try await Post.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await post.delete(on: req.db)
        return req.redirect(to: "/page/posts")
    }


    // 列表页
    func indexPage(req: Request) async throws -> View {
        let posts = try await Post.query(on: req.db).sort(\.$createdAt, .descending).all()
        return try await req.view.render("posts/index", ["posts": posts])
    }

    // 创建页
    func createPage(req: Request) async throws -> View {
        return try await req.view.render("posts/create")
    }

    // 详情页（可选）
    func showPage(req: Request) async throws -> View {
        guard let post = try await Post.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await req.view.render("posts/show", ["post": post])
    }

    // 编辑页
    func editPage(req: Request) async throws -> View {
        guard let post = try await Post.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return try await req.view.render("posts/edit", ["post": post])
    }
}
