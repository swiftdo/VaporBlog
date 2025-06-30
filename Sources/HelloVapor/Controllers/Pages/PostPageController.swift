import Vapor
struct PostPageController: RouteCollection, @unchecked Sendable {

    let postService: any PostService

    init(postService: any PostService) {
        self.postService = postService
    }

    func boot(routes: any RoutesBuilder) throws {
        let posts = routes.grouped("posts").grouped(UserAuthenticatorMiddleware())
        
        let secure = posts.grouped(UserAuthenticatorMiddleware())
        // GET 请求：页面展示
        posts.get(use: indexPage)                // 列表页面
        posts.get("create", use: createPage)     // 创建页面
        posts.get(":id", use: showPage)          // 详情页面
        posts.get(":id", "edit", use: editPage)  // 编辑页面
        
        // 数据操作
        secure.post(use: storeAction)             // 创建资源
        secure.post(":id", "update", use: updateAction)     // 更新资源, 因为表单不支持 put
        secure.post(":id", "delete", use: deleteAction)   // 删除资源, 因为表单不支持 delete
    }
    
    // 保存新文章
    func storeAction(req: Request) async throws -> Response {
        let userPayload = try req.auth.require(UserPayload.self)
        let input = try req.content.decode(InPost.self)
        let _ = try await postService.create(input: input, userId: userPayload.userId, req: req)
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
        let payload = req.auth.get(UserPayload.self)
        let posts = try await Post.query(on: req.db).with(\.$author).sort(\.$createdAt, .descending).all()

        var context: [String: AnyEncodable] = [
            "posts": AnyEncodable(value: posts.map { OutPost(from: $0) }),
        ]
        var user: OutUser? 
        if let payload, let dbuser = try await User.find(payload.userId, on: req.db) {
            user = OutUser(user: dbuser)
            context["user"] = AnyEncodable(value: user)
        }
        
        return try await req.view.render("posts/index", context)
    }

    // 创建页
    func createPage(req: Request) async throws -> View {
        let payload = req.auth.get(UserPayload.self)

    
    

        var user: OutUser? 


        var context: [String: AnyEncodable] = [:]
        if let payload, let dbuser = try await User.find(payload.userId, on: req.db) {
            user = OutUser(user: dbuser)
            context["user"] = AnyEncodable(value: user)
        }

        let categories = try await Category.query(on: req.db).all()
        let tags = try await Tag.query(on: req.db).all()
        context["categories"] = AnyEncodable(value: categories)
        context["tags"] = AnyEncodable(value: tags)

        return try await req.view.render("posts/create", context)
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
