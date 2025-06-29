import Vapor 
import Fluent

final class PostTag: Model, Content, @unchecked Sendable {
    static let schema = "post_tags"

    enum FieldKeys {
        static let id: FieldKey = "id"
        static let postId: FieldKey = "post_id"
        static let tagId: FieldKey = "tag_id"
        static let createdAt: FieldKey = "created_at"
        static let updatedAt: FieldKey = "updated_at"
    }

    @ID(key: .id)
    var id: UUID?

    @Parent(key: FieldKeys.postId)
    var post: Post

    @Parent(key: FieldKeys.tagId)
    var tag: Tag

    @Timestamp(key: FieldKeys.createdAt, on: .create)
    var createdAt: Date?

    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    var updatedAt: Date?

    init() {}

    init(postId: UUID, tagId: UUID) {
        self.$post.id = postId
        self.$tag.id = tagId
    }
}