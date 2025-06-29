import Vapor 
import Fluent

 struct CreateTag: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Tag.schema)
            .id()
            .field(Tag.FieldKeys.name, .string, .required)
            .field(Tag.FieldKeys.description, .string)
            .field(Tag.FieldKeys.createdAt, .datetime, .required)
            .field(Tag.FieldKeys.updatedAt, .datetime, .required)
            .unique(on: Tag.FieldKeys.name) // 确保标签名称唯一
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Tag.schema).delete()
    }
 }