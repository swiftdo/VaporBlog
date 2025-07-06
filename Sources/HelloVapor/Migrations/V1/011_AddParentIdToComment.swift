import Vapor
import Fluent

struct AddParentIdToComment: AsyncMigration {

    func prepare(on database: any Database) async throws {
        try await database
            .schema(Comment.schema)
            .field(Comment.FieldKeys.parentId, .uuid, .references(Comment.schema, Comment.FieldKeys.id, onDelete: .cascade))
            .update()
    }

    func revert(on database: any Database) async throws {

        try await database
            .schema(Comment.schema)
            .deleteField(Comment.FieldKeys.parentId)
            .update()
    }

}