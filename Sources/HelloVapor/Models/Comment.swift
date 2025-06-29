import Vapor
import Fluent

final class Comment: Model, Content, @unchecked Sendable {
    static let schema = "comments"

    enum FieldKeys {
        static let id: FieldKey = "id"
        static let postId: FieldKey = "post_id"
        static let authorId: FieldKey = "author_id"
        static let parentId: FieldKey = "parent_id"
        static let content: FieldKey = "content"
        static let status: FieldKey = "status" // 评论状态
        static let createdAt: FieldKey = "created_at"
        static let updatedAt: FieldKey = "updated_at"
    }

    @ID(key: .id)
    var id: UUID?

    @Parent(key: FieldKeys.postId)
    var post: Post

    @Parent(key: FieldKeys.authorId)
    var author: User

    @Field(key: FieldKeys.content)
    var content: String

    @Field(key: FieldKeys.status)
    var status: String // 评论状态，使用枚举类型

    @OptionalParent(key: FieldKeys.parentId)
    var parent: Comment? // 可选的父评论，用于支持评论的嵌套

    @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?

    @Children(for: \.$parent)
    var replies: [Comment] // 该评论的所有回复（子评论）

    init() {}

    init(id: UUID? = nil, postId: UUID, authorId: UUID, content: String, status: Status = .pending, parentId: UUID? = nil) {
        self.id = id
        self.$post.id = postId
        self.$author.id = authorId
        self.content = content
        self.status = status.rawValue
        self.$parent.id = parentId
    }
}

extension Comment {
    /// 评论状态枚举，定义了评论的不同状态。
    enum Status: String, Codable {
        case pending = "pending" // 待审核
        case approved = "approved" // 已审核
        case rejected = "rejected" // 已拒绝
        case spam = "spam" // 垃圾评论
    }
}
