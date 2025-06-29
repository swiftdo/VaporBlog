import Vapor 
protocol PostService {
    func create(input: InPost, userId: UUID, req: Request) async throws -> OutPost
}