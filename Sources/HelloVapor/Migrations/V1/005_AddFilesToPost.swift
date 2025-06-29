import Vapor 
import Fluent

struct AddFilesToPost: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Post.schema)
            .field(Post.FieldKeys.authorId, .uuid, .required, .references(User.schema, .id)) // 关联用户的外键
            .field(Post.FieldKeys.excerpt, .string) // 文章摘要
            .field(Post.FieldKeys.status, .string, .required) // 文章状态
            .field(Post.FieldKeys.viewsCount, .int, .required, .custom("DEFAULT 0")) // 文章浏览量
            .field(Post.FieldKeys.publishedAt, .datetime) // 文章发布时间
            .update()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Post.schema)
            .deleteField(Post.FieldKeys.authorId) // 删除与用户的关联
            .deleteField(Post.FieldKeys.excerpt)
            .deleteField(Post.FieldKeys.status)
            .deleteField(Post.FieldKeys.viewsCount)
            .deleteField(Post.FieldKeys.publishedAt)
            .update()
    }
}