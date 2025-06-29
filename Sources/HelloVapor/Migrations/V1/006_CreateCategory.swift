import Vapor
import Fluent

struct CreateCategory: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(Category.schema)
            .id()
            .field(Category.FieldKeys.name, .string, .required)
            .field(Category.FieldKeys.description, .string)
            .field(Category.FieldKeys.createdAt, .datetime, .required)
            .field(Category.FieldKeys.updatedAt, .datetime, .required)
            .unique(on: Category.FieldKeys.name) // 确保分类名称唯一
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(Category.schema).delete()
    }
}