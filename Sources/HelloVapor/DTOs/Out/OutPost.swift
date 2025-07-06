//
//  OutPost.swift
//  HelloVapor
//
//  Created by laijihua on 2025/6/6.
//

import Vapor

struct OutPost: Out {
    let id: UUID
    let title: String
    let content: String
    let createdAt: Date?
    let viewsCount: Int // 添加文章阅读量
    let updatedAt: Date?
    let authorId: UUID
    let excerpt: String?
    let status: String?
    let author: OutUser?
    let categories: [OutCategory]
    let tags: [OutTag]
    let comments: [OutComment]
    
    // 专业推荐：DTO 层负责转换，解耦模型
    init(from post: Post, comments: [OutComment] = []) {
        self.id = post.id!
        self.title = post.title
        self.content = post.content
        self.createdAt = post.createdAt
        self.updatedAt = post.updatedAt
        self.authorId = post.$author.id
        self.excerpt = post.excerpt
        self.status = post.status
        self.viewsCount = post.viewsCount

        if let user = post.$author.value {
            self.author = OutUser(user: user)
        } else {
            self.author = nil
        }

        if let categories = post.$categories.value {
            self.categories = categories.map { OutCategory(from: $0) }
        } else {
            self.categories = []
        }

        if let tags = post.$tags.value {
            self.tags = tags.map { OutTag(from: $0) }
        } else {
            self.tags = []
        }
        self.comments = comments     
    }
}
