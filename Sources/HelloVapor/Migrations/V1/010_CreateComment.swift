import Vapor
import Fluent

struct CreateComment: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Comment.schema)
            .id()
            .field(Comment.FieldKeys.postId, .uuid, .required, .references(Post.schema, .id, onDelete: .cascade))
            .field(Comment.FieldKeys.authorId, .uuid, .required, .references(User.schema, .id, onDelete: .cascade))
            .field(Comment.FieldKeys.content, .string, .required)
            .field(Comment.FieldKeys.status, .string, .required) // 评论状态
            .field(Comment.FieldKeys.createdAt, .datetime, .required)
            .field(Comment.FieldKeys.updatedAt, .datetime, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Comment.schema).delete()
    }
}