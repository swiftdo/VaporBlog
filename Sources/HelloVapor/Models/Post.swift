//
//  Post.swift
//  HelloVapor
//
//  Created by laijihua on 2025/6/2.
//
import Fluent
import Vapor

/// `Post` 模型代表数据库中的 `posts` 表。
/// 同时遵循 `Content` 协议，方便与 JSON 互相转换，这对于构建 RESTful API 至关重要。
final class Post: Model, Content, @unchecked Sendable {
    // 定义数据库表名，Vapor/Fluent 会自动识别并操作这张表
    static let schema = "posts"
    
    enum FieldKeys {
        static let title: FieldKey = "title"
        static let content: FieldKey = "content"
        static let createdAt: FieldKey = "created_at"
        static let updatedAt: FieldKey = "updated_at"
    }

    // MARK: - 数据库字段定义

    /// 主键，使用 `@ID` 宏。通常是 UUID 或 Int。
    /// `key: .id` 是 Fluent 的约定，映射到数据库中的 `id` 列。
    /// 对于 PostgreSQL，通常推荐使用 UUID 作为主键。
    @ID(key: .id)
    var id: UUID?

    /// 文章标题字段，使用 `@Field` 宏。
    @Field(key: FieldKeys.title)
    var title: String

    /// 文章内容字段。
    @Field(key: FieldKeys.content)
    var content: String

    /// 创建时间戳，使用 `@Timestamp` 宏，`on: .create` 表示在创建记录时自动设置。
    @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?

    /// 更新时间戳，`on: .update` 表示在更新记录时自动设置。
    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?

    // MARK: - 初始化方法

    /// Fluent 要求提供一个无参数的初始化方法，供其内部实例化模型。
    init() { }

    /// 自定义初始化方法，方便我们在代码中创建 `Post` 实例。
    init(id: UUID? = nil, title: String, content: String) {
        self.id = id
        self.title = title
        self.content = content
    }
}
