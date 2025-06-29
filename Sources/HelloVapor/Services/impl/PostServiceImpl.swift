import Vapor
import Fluent

final class PostServiceImpl: PostService { 

    func create(input: InPost, userId: UUID, req: Request) async throws -> OutPost {
        let post = Post(
            title: input.title, 
            content: input.content, 
            authorId: userId, 
            excerpt: input.excerpt, 
            status: input.status ?? .draft,
            publishedAt: input.status == .published ? Date() : nil
        )
        // 处理分类和标签
        return try await req.db.transaction { db  in
            try await post.create(on: db)
            // 处理分类和标签
            if let categoryIds = input.categoryIds {
                let categoryIDs = categoryIds.split(separator: ",").compactMap { UUID(uuidString: String($0)) }
                let categories = try await Category.query(on: db)
                    .filter(\.$id ~~ categoryIDs)
                    .all()
                try await post.$categories.attach(categories, on: db)
            }
            if let tagIds = input.tagIds {
                let tagIDs = tagIds.split(separator: ",").compactMap { UUID(uuidString: String($0)) }
                let tags = try await Tag.query(on: db)
                    .filter(\.$id ~~ tagIDs)
                    .all()
                try await post.$tags.attach(tags, on: db)
            }
            return  OutPost(from: post)
        }
    }
}
