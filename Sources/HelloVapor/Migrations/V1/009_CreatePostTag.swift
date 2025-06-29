import Vapor
import Fluent

struct CreatePostTag: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(PostTag.schema)
            .id()
            .field(PostTag.FieldKeys.postId, .uuid, .required, .references(Post.schema, .id, onDelete: .cascade))
            .field(PostTag.FieldKeys.tagId, .uuid, .required, .references(Tag.schema, .id, onDelete: .cascade))
            .field(PostTag.FieldKeys.createdAt, .datetime, .required)
            .field(PostTag.FieldKeys.updatedAt, .datetime, .required)
            .unique(on: PostTag.FieldKeys.postId, PostTag.FieldKeys.tagId) // 确保每个文章和标签的组合唯一
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(PostTag.schema).delete()
    }
}