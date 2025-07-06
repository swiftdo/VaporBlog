import Vapor 
import Fluent

final class CommentServiceImpl: CommentService { 

    func create(input: InComment, for post: Post, user: User, req: Request) async throws -> OutComment {
        let comment = Comment(postId: try  post.requireID(), authorId: try user.requireID(), content: input.content)
        try await comment.save(on: req.db)
        // 发表评论
        return OutComment(from: comment)
    }

    func find(id: Comment.IDValue, req: Request) async throws -> Comment? {
        let comment = try await Comment.query(on: req.db)
            .filter(\.$id == id)
            .with(\.$author)
            .first()
        
        return comment
    }

    func addReply(input: InComment, for post: Post, user: User, comment: Comment, req: Request) async throws -> OutComment {
    
        let reply = Comment(
            postId: try post.requireID(), 
            authorId: try user.requireID(), 
            content: input.content, 
            parentId: try comment.requireID(),
        )

        try await reply.save(on: req.db)

        return OutComment(from: reply)
    }

}
