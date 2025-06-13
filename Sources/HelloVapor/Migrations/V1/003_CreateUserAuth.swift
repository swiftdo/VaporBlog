import Fluent

struct CreateUserAuth: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(UserAuth.schema)
            .id()
            .field(UserAuth.FieldKeys.userId, .uuid, .required, .references(User.schema, .id))
            .field(UserAuth.FieldKeys.authType, .string, .required)
            .field(UserAuth.FieldKeys.identifier, .string, .required)
            .field(UserAuth.FieldKeys.credential, .string)
            .field(UserAuth.FieldKeys.createdAt, .datetime, .required)
            .unique(on: UserAuth.FieldKeys.authType, UserAuth.FieldKeys.credential)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(UserAuth.schema).delete()
    }
}