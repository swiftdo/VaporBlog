import Vapor 
import Fluent

protocol PostService {

    func list(req: Request) async throws -> Page<OutPost>

    func create(input: InPost, userId: UUID, req: Request) async throws -> OutPost

    func update(input: InPost, post: Post, req: Request) async throws -> OutPost

    func detail(postId: UUID, req: Request, viewCountIns: Bool) async throws -> OutPost?

    func find(postId: UUID, req: Request) async throws -> Post?

    func delete(post: Post, req: Request) async throws
}

extension PostService { 
    func detail(postId: UUID, req: Request) async throws -> OutPost? {
        return try await detail(postId: postId, req: req, viewCountIns: false)
    }
}