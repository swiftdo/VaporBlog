import Vapor 
import Fluent

protocol PostService {

    func list(req: Request) async throws -> Page<OutPost>

    func create(input: InPost, userId: UUID, req: Request) async throws -> OutPost

    func update(input: InPost, post: Post, req: Request) async throws -> OutPost

    /// 获取文章详情
    /// [withComment] 是否参数是是否获取评论
    func detail(postId: UUID, req: Request, viewCountIns: Bool, withComment: Bool) async throws -> OutPost?

    func find(postId: UUID, req: Request) async throws -> Post?

    func delete(post: Post, req: Request) async throws
}

extension PostService { 
    func detail(postId: UUID, req: Request) async throws -> OutPost? {
        return try await detail(postId: postId, req: req, viewCountIns: false)
    }

    func detail(postId: UUID, req: Request, viewCountIns: Bool) async throws -> OutPost? {
        return try await detail(postId: postId, req: req, viewCountIns: viewCountIns, withComment: false)
    }
}