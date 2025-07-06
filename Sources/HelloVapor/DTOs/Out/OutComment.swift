import Vapor 
struct OutComment: Out {

    var id: UUID?
    var postId: UUID
    var authorId: UUID
    var author: OutUser?
    var content: String
    var status: String // 评论状态，使用枚举类型
    var parentId: UUID? // 可选的父评论，用于支持评论的嵌套
    var createdAt: Date?
    var updatedAt: Date?
    var replies: [OutComment]

    init(from comment: Comment, replies: [OutComment] = []) {
        self.id = comment.id
        self.postId = comment.$post.id
        self.authorId = comment.$author.id

        if let author = comment.$author.value {
            self.author = OutUser(user: author)
        }
        self.content = comment.content
        self.status = comment.status
        self.parentId = comment.$parent.id
        self.createdAt = comment.createdAt
        self.updatedAt = comment.updatedAt
        self.replies = replies
    }
}