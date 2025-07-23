import Vapor
import Fluent

import Vapor
import Fluent

// 首页
struct AuthorPageController: RouteCollection, @unchecked Sendable {

    let postService: any PostService

    init(postService: any PostService) {
        self.postService = postService
    }

    func boot(routes: any RoutesBuilder) throws {
        let posts = routes.grouped("authors")
            .grouped(UserAuthenticatorMiddleware())
        // GET 请求：页面展示
        posts.get(use: indexPage)                // 列表页面    

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
            "pageNumbers": AnyEncodable(value: Array(1...paged.metadata.pageCount)),
        ]
        var user: OutUser? 
        if let payload, let dbuser = try await User.find(payload.userId, on: req.db) {
            user = OutUser(user: dbuser)
            context["user"] = AnyEncodable(value: user)
        }
        // 获取推荐作者
        // 获取推荐标签
        // 获取推荐分类 

        context["authors"] = AnyEncodable(value: [OutUser]())
        context["tags"] = AnyEncodable(value: [OutTag]())
        context["categories"] = AnyEncodable(value: [OutCategory]())
        return try await req.view.render("authors/index", context)
    }
}
