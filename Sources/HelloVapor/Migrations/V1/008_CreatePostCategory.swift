import Vapor
import Fluent

struct CreatePostCategory: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(PostCategory.schema)
            .id()
            .field(PostCategory.FieldKeys.postId, .uuid, .required, .references(Post.schema, .id, onDelete: .cascade))
            .field(PostCategory.FieldKeys.categoryId, .uuid, .required, .references(Category.schema, .id, onDelete: .cascade))
            .field(PostCategory.FieldKeys.createdAt, .datetime, .required)
            .field(PostCategory.FieldKeys.updatedAt, .datetime, .required)
            .unique(on: PostCategory.FieldKeys.postId, PostCategory.FieldKeys.categoryId) // 确保每个文章和分类的组合唯一
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(PostCategory.schema).delete()
    }
}