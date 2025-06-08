//
//  CreatePost.swift
//  HelloVapor
//
//  Created by laijihua on 2025/6/2.
//

import Fluent
/// `CreatePost` 是一个 Fluent 迁移，用于在数据库中创建 `posts` 表。
struct CreatePost: AsyncMigration { // 遵循 AsyncMigration 协议，支持异步操作
    /// `prepare` 方法用于定义数据库表的创建逻辑。
    /// 它会在应用启动时，如果尚未运行过该迁移，则自动执行。
    func prepare(on database: any Database) async throws {
       
        try await database.schema(Post.schema) // 指定要操作的表名，即 "posts"
            .id() // 添加主键字段 (id)，类型由模型中的 @ID 定义决定（UUID 或 Int）
            .field(Post.FieldKeys.title, .string, .required) // 添加 title 字段，字符串类型，非空约束
            .field(Post.FieldKeys.content, .string, .required) // 添加 content 字段，字符串类型，非空约束
            .field(Post.FieldKeys.createdAt, .datetime) // 添加 created_at 字段，日期时间类型，可为空
            .field(Post.FieldKeys.updatedAt, .datetime) // 添加 updated_at 字段，日期时间类型，可为空
            .create() // 执行创建表操作
    }

    /// `revert` 方法用于定义数据库表的删除逻辑。
    /// 这个方法主要用于开发阶段的回滚（rollback）操作，例如当你需要撤销某个迁移时。
    func revert(on database: any Database) async throws {
        try await database.schema(Post.schema)
            .delete() // 删除 posts 表
    }
}
