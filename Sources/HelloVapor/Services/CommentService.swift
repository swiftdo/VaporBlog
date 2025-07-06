import Vapor

protocol CommentService {
    func create(input: InComment, for post: Post, user: User, req: Request) async throws -> OutComment
    func find(id: Comment.IDValue, req: Request) async throws -> Comment?

    /// 评论添加回
    func addReply(input: InComment, for post: Post, user: User, comment: Comment, req: Request) async throws -> OutComment

}