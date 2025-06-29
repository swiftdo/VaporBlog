import Fluent 
import Vapor 

final class Category: Model, Content, @unchecked Sendable {
    enum FieldKeys {
        static let id: FieldKey = "id"
        static let name: FieldKey = "name"
        static let description: FieldKey = "description"
        static let createdAt: FieldKey = "created_at"
        static let updatedAt: FieldKey = "updated_at"
    }

    static let schema = "categories"

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


    // 与 Posts 的关系：多对多
    // through: PostCategory.self 指定中间表模型。
    // from: \.$category 指向中间表中的 Category 字段。
    // to: \.$post 指向中间表中的 Post 字段。
    // 一个 Category 可以包含多篇文章。
    @Siblings(through: PostCategory.self, from: \.$category, to: \.$post)
    public var posts: [Post] // 属于该分类的所有文章

    init() {}

    init(name: String, description: String) {
        self.name = name
        self.description = description
    }
}