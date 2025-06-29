import Vapor 
import Fluent

final class PostCategory: Model, Content, @unchecked Sendable {
    enum FieldKeys {
        static let id: FieldKey = "id"
        static let postId: FieldKey = "post_id"
        static let categoryId: FieldKey = "category_id"
        static let createdAt: FieldKey = "created_at"
        static let updatedAt: FieldKey = "updated_at"
    }

    static let schema = "post_categories"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: FieldKeys.postId)
    var post: Post

    @Parent(key: FieldKeys.categoryId)
    var category: Category

    @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?

    init() {}

    init(postId: UUID, categoryId: UUID) {
        self.$post.id = postId
        self.$category.id = categoryId
    }
}