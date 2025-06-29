import Vapor 
import Fluent

final class Tag: Model, Content, @unchecked Sendable {
    enum FieldKeys {
        static let id: FieldKey = "id"
        static let name: FieldKey = "name"
        static let description: FieldKey = "description"
        static let createdAt: FieldKey = "created_at"
        static let updatedAt: FieldKey = "updated_at"
    }

    static let schema = "tags"

    @ID(key: .id)
    var id: UUID?

    @Field(key: FieldKeys.name)
    var name: String

    @OptionalField(key: FieldKeys.description)
    var description: String?

    @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?

     // MARK: - 关系定义

    // 与 Posts 的关系：多对多
    // 一个 Tag 可以关联多篇文章。
    @Siblings(through: PostTag.self, from: \.$tag, to: \.$post)
    public var posts: [Post] // 关联该标签的所有文章

    init() {}

    init(name: String, description: String? = nil) {
        self.name = name
        self.description = description
    }
}