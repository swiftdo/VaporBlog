import Vapor
import Fluent

struct PostPageController: RouteCollection, @unchecked Sendable {

    let postService: any PostService
    let commentService: any CommentService

    init(postService: any PostService, commentService: any CommentService) {
        self.postService = postService
        self.commentService = commentService
    }

    func boot(routes: any RoutesBuilder) throws {
        let posts = routes.grouped("posts")
            .grouped(UserAuthenticatorMiddleware())
        
        // GET 请求：页面展示
        posts.get(use: indexPage)                // 列表页面
        posts.get("create", use: createPage)     // 创建页面
        posts.get(":id", use: showPage)          // 详情页面
        posts.get(":id", "edit", use: editPage)  // 编辑页面
        
        // 数据操作
        posts.post(use: storeAction)             // 创建资源
        posts.post(":id", "update", use: updateAction)     // 更新资源, 因为表单不支持 put
        posts.post(":id", "delete", use: deleteAction)   // 删除资源, 因为表单不支持 delete

        posts.post(":id", "comment", use: postAddComment) // 添加评论
        posts.post(":id", "comments", ":commentId", "reply", use: postCommentAddReply) 

    }

    private func postAddComment(req: Request) async throws -> Response {
        let userPayload = try req.auth.require(UserPayload.self)
        // 获取到这个用户，判断是否有评论权限，判断是否被禁
        guard let dbuser = try await User.find(userPayload.userId, on: req.db) else {
            throw Abort(.notFound)
        }

        guard let postId = req.parameters.get("id"), let postUuid = UUID(uuidString: postId) else {
            throw Abort(.notFound)
        }

        guard let post = try await postService.find(postId: postUuid, req: req) else {
            throw Abort(.notFound)
        }

        let input = try req.content.decode(InComment.self)

        let _ = try await commentService.create(input: input, for: post, user: dbuser, req: req)

        return req.redirect(to: "/page/posts/\(postId)")
    }
    
    private func postCommentAddReply(req: Request) async throws -> Response {
        let userPayload = try req.auth.require(UserPayload.self)
        guard let dbuser = try await User.find(userPayload.userId, on: req.db) else {
            throw Abort(.notFound)
        }

        guard let postId = req.parameters.get("id"), let postUuid = UUID(uuidString: postId) else {
            throw Abort(.notFound)
        }

        guard let post = try await postService.find(postId: postUuid, req: req) else {
            throw Abort(.notFound)
        }

        guard let commentId = req.parameters.get("commentId"), let commentUuid = UUID(uuidString: commentId) else {
            throw Abort(.notFound)
        }

        guard let comment = try await commentService.find(id: commentUuid, req: req) else {
            throw Abort(.notFound)
        }

         let input = try req.content.decode(InComment.self)
    
        let _ = try await commentService
            .addReply(input: input, for: post, user: dbuser, comment: comment, req: req)
        return req.redirect(to: "/page/posts/\(postId)")
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
        let userPayload = try req.auth.require(UserPayload.self)
        guard let dbuser = try await User.find(userPayload.userId, on: req.db) else {
            throw Abort(.notFound)
        }

        guard let postId = req.parameters.get("id"), let uuid = UUID(uuidString: postId) else {
            throw Abort(.notFound)
        }

        guard let post = try await postService.find(postId: uuid, req: req) else {
            throw Abort(.notFound)
        }
        if post.$author.id != dbuser.id {
            throw Abort(.forbidden, reason: "You are not allowed to edit this post.")
        }

        let input = try req.content.decode(InPost.self)
        let _ = try await postService.update(input: input, post: post, req: req)

        return req.redirect(to: "/page/posts")
    }

    // 删除文章
    func deleteAction(req: Request) async throws -> Response {
        guard let post = try await Post.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        try await postService.delete(post: post, req: req)
        return req.redirect(to: "/page/posts")
    }

    // 列表页
    func indexPage(req: Request) async throws -> View {
        let payload = req.auth.get(UserPayload.self)


        let pageReq = try req.query.decode(PageRequest.self)
        let paged = try await postService.list(req: req)

        let startPage = max(2, pageReq.page - 2)
        let endPage = min(paged.metadata.pageCount - 1, pageReq.page + 2)            

        var context: [String: AnyEncodable] = [
            "items": AnyEncodable(value: paged.items),
            "per": AnyEncodable(value: paged.metadata.per),
            "page": AnyEncodable(value: paged.metadata.page),
            "pageCount": AnyEncodable(value: paged.metadata.pageCount),
            "total": AnyEncodable(value: paged.metadata.total),
            "startPage": AnyEncodable(value: startPage),
            "endPage": AnyEncodable(value: endPage),
            "pageNumbers": AnyEncodable(value: Array(1...paged.metadata.pageCount))
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

        let payload = req.auth.get(UserPayload.self)
        var user: OutUser? 
        var context: [String: AnyEncodable] = [:]
        if let payload, let dbuser = try await User.find(payload.userId, on: req.db) {
            user = OutUser(user: dbuser)
            context["user"] = AnyEncodable(value: user)
        }
        guard let postId = req.parameters.get("id"), let uuid = UUID(uuidString: postId) else {
            throw Abort(.notFound)
        }
        
        // 查询文章，增加阅读量
        guard let post = try await postService.detail(postId: uuid, req: req, viewCountIns: true, withComment: true) else {
            throw Abort(.notFound)
        }
        context["post"] = AnyEncodable(value: post)
        // 渲染视图
        return try await req.view.render("posts/show", context)
        
    }

    // 编辑页
    func editPage(req: Request) async throws -> View {
        let payload = try req.auth.require(UserPayload.self)

        guard let postId = req.parameters.get("id"), let uuid = UUID(uuidString: postId) else {
            throw Abort(.notFound)
        }
        
        // 查询文章
        guard let post = try await postService.detail(postId: uuid, req: req) else {
            throw Abort(.notFound)
        }

        guard let dbuser = try await User.find(payload.userId, on: req.db) else {
            throw Abort(.notFound)
        }

        var context: [String: AnyEncodable] = [:]
        context["user"] = AnyEncodable(value: OutUser(user: dbuser))        
        let categories = try await Category.query(on: req.db).all()
        let tags = try await Tag.query(on: req.db).all()
        context["categories"] = AnyEncodable(value: categories)
        context["tags"] = AnyEncodable(value: tags)
        context["post"] = AnyEncodable(value: post)
        return try await req.view.render("posts/edit", context)
    }
}
