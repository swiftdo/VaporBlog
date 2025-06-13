import Fluent

struct CreateRefreshToken: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(RefreshToken.schema)
            .id()
            .field(RefreshToken.FieldKeys.userId, .uuid, .required, .references(User.schema, .id))
            .field(RefreshToken.FieldKeys.token, .string, .required)
            .field(RefreshToken.FieldKeys.expiresAt, .datetime, .required)
            .field(RefreshToken.FieldKeys.createdAt, .datetime, .required)
            .unique(on: RefreshToken.FieldKeys.token)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(RefreshToken.schema).delete()
    }
}