
import Fluent

struct CreateUser: AsyncMigration {
   
   func prepare(on database: any Database) async throws {

        try await database.schema(User.schema)
            .id()
            .field(User.FieldKeys.nickname, .string, .required)
            .field(User.FieldKeys.status, .int, .required)
            .field(User.FieldKeys.createdAt, .datetime, .required)
            .field(User.FieldKeys.updatedAt, .datetime, .required)
            .create()
   }

   func revert(on database: any Database) async throws {
        try await database.schema(User.schema).delete()
   }
}