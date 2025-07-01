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

    func update(input: InPost, post: Post, req: Request) async throws -> OutPost {

        post.title = input.title
        post.content = input.content
        post.excerpt = input.excerpt
        post.status = input.status != nil ? input.status!.rawValue : Post.Status.draft.rawValue

        if post.publishedAt == nil && input.status == .published {
            post.publishedAt = Date() // 如果状态变为已发布，设置发布时间
        }

        return try await req.db.transaction { db in 
            var delCates: [Category] = []
            var delTags: [Tag] = []
            var addCates: [Category] = []
            var addTags: [Tag] = []

            
            // 处理分类和标签
            if let categoryIds = input.categoryIds {
                let categoryIDs = categoryIds.split(separator: ",").compactMap { UUID(uuidString: String($0)) }

                let categories = try await Category.query(on: db)
                    .filter(\.$id ~~ categoryIDs)
                    .all()

                // 1. 获取当前已关联的分类
                let currentCategories = post.categories;

                // 2. 需要删除的分类：原有但现在没选中的
                delCates = currentCategories.filter { !categoryIDs.contains($0.id!) }
                
                // 3. 需要新增的分类：现在选中的但原来没有的
                let currentIDs = Set(currentCategories.compactMap { $0.id })
                addCates = categories.filter { !currentIDs.contains($0.id!) }
            }

            if let tagIds = input.tagIds {
                let tagIDs = tagIds.split(separator: ",").compactMap { UUID(uuidString: String($0)) }

                let tags = try await Tag.query(on: db)
                    .filter(\.$id ~~ tagIDs)
                    .all()

                // 1. 获取当前已关联的标签
                let currentTags = post.tags;

                // 2. 需要删除的标签：原有但现在没选中的
                delTags = currentTags.filter { !tagIDs.contains($0.id!) }
                // 3. 需要新增的标签：现在选中的但原来没有的
                let currentIDs = Set(currentTags.compactMap { $0.id })
                addTags = tags.filter { !currentIDs.contains($0.id!) }
            }

            for tag in addTags {
                try await post.$tags.attach(tag, on: db)
            }
            for cate in delCates {
                try await post.$categories.detach(cate, on: db)
            }
            for cate in addCates {
                try await post.$categories.attach(cate, on: db)
            }
            for tag in delTags {
                try await post.$tags.detach(tag, on: db)
            }
            try await post.save(on: db)
            return OutPost(from: post)
        }    
    }

    // private func updateSiblings<From, To, Through>(
    //     from: From,
    //     relation: KeyPath<From, SiblingsProperty<From, To, Through>>,
    //     newIDs: [To.IDValue],
    //     db: any Database
    // ) async throws where From: Model, To: Model, Through: Model {
    //     let currentItems = try await from[keyPath: relation].get(on: db)
    //     let currentIDs = Set(currentItems.compactMap { $0.id })
    //     let toAddIDs = Set(newIDs).subtracting(currentIDs)
    //     let toDelIDs = currentIDs.subtracting(newIDs)

    //     // 新增
    //     if !toAddIDs.isEmpty {
    //         let toAdd = try await To.query(on: db).filter(\._$id ~~ Array(toAddIDs)).all()
    //         for item in toAdd {
    //             try await from[keyPath: relation].attach(item, on: db)
    //         }
    //     }
    //     // 删除
    //     if !toDelIDs.isEmpty {
    //         let toDel = currentItems.filter { toDelIDs.contains($0.id!) }
    //         for item in toDel {
    //             try await from[keyPath: relation].detach(item, on: db)
    //         }
    //     }
    // }
}
