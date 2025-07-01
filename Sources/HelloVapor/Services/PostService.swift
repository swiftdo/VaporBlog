import Vapor 
protocol PostService {
    func create(input: InPost, userId: UUID, req: Request) async throws -> OutPost

    func update(input: InPost, post: Post, req: Request) async throws -> OutPost
}