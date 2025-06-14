import Fluent

struct CreateEmailVerifyCode: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema(EmailVerifyCode.schema)
            .id()
            .field(EmailVerifyCode.FieldKeys.email, .string, .required)
            .field(EmailVerifyCode.FieldKeys.code, .string, .required)
            .field(EmailVerifyCode.FieldKeys.type, .string, .required)
            .field(EmailVerifyCode.FieldKeys.expiredAt, .datetime, .required)
            .field(EmailVerifyCode.FieldKeys.createdAt, .datetime, .required)
            .field(EmailVerifyCode.FieldKeys.updatedAt, .datetime, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema(EmailVerifyCode.schema).delete()
    }
}