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
    
    

    // MARK: - 数据库字段定义

    /// 主键，使用 `@ID` 宏。通常是 UUID 或 Int。
    /// `key: .id` 是 Fluent 的约定，映射到数据库中的 `id` 列。
    /// 对于 PostgreSQL，通常推荐使用 UUID 作为主键。
    @ID(key: .id)
    var id: UUID?

    @Parent(key: FieldKeys.authorId)
    var author: User // 关联到 `User` 模型，表示文章的作者

    /// 文章标题字段，使用 `@Field` 宏。
    @Field(key: FieldKeys.title)
    var title: String

    /// 文章内容字段。
    @Field(key: FieldKeys.content)
    var content: String

    @OptionalField(key: FieldKeys.excerpt)
    var excerpt: String? // 文章摘要，可选字段

    @Field(key: FieldKeys.status)
    var status: String // 文章状态，通常使用枚举类型表示不同状态

    @Field(key: FieldKeys.viewsCount)
    var viewsCount: Int // 文章浏览量，通常是一个整数

    @Field(key: FieldKeys.publishedAt)
    var publishedAt: Date? // 文章发布时间

    /// 创建时间戳，使用 `@Timestamp` 宏，`on: .create` 表示在创建记录时自动设置。
    @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?

    /// 更新时间戳，`on: .update` 表示在更新记录时自动设置。
    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?

    // MARK: - 关系定义

    // @Siblings 属性包装器：定义多对多关系。
    // through: PostCategory.self 指定中间表模型。
    // from: \.$post 指向中间表中的 Post 字段。
    // to: \.$category 指向中间表中的 Category 字段。
    // 一篇文章可以有多个 Category。
    @Siblings(through: PostCategory.self, from: \.$post, to: \.$category)
    public var categories: [Category] // 文章所属的分类

    // 与 Tags 的关系：多对多
    // 一篇文章可以有多个 Tag。
    @Siblings(through: PostTag.self, from: \.$post, to: \.$tag)
    public var tags: [Tag] // 文章关联的标签

    // 与 Comments 的关系：一对多
    // for: \.$post 表示 Comment 模型中的 $post 字段指向当前 Post。
    // 一篇文章可以有多条 Comment。
    @Children(for: \.$post)
    var comments: [Comment] // 文章下的所有评论


    // MARK: - 初始化方法

    /// Fluent 要求提供一个无参数的初始化方法，供其内部实例化模型。
    init() { }

    /// 自定义初始化方法，方便我们在代码中创建 `Post` 实例。
    init(title: String, content: String, authorId: UUID, excerpt: String? = nil, status: Status = .draft, viewsCount: Int = 0, publishedAt: Date? = nil) {
        self.title = title
        self.content = content
        self.$author.id = authorId
        self.excerpt = excerpt
        self.status = status.rawValue
        self.viewsCount = viewsCount
        self.publishedAt = publishedAt
    }
}

extension Post {
    /// 文章状态枚举，定义了文章的不同状态。
    enum Status: String, Codable {
        case draft = "draft" // 草稿
        case published = "published" // 已发布
        case archived = "archived" // 已归档
    }

    enum FieldKeys {
        static let title: FieldKey = "title" // 标题
        static let content: FieldKey = "content" // 内容
        static let createdAt: FieldKey = "created_at"
        static let updatedAt: FieldKey = "updated_at"

        static let authorId: FieldKey = "author_id" // 关联用户的外键
        static let excerpt: FieldKey = "excerpt" // 文章摘要
        static let status: FieldKey = "status" // 文章状态
        static let viewsCount: FieldKey = "views_count" // 文章浏览量
        static let publishedAt: FieldKey = "published_at" // 文章发布时间
    }
}
