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
    let updatedAt: Date?
    let authorId: UUID
    let excerpt: String?
    let status: String?
    let author: OutUser?

    // 专业推荐：DTO 层负责转换，解耦模型
    init(from post: Post) {
        self.id = post.id!
        self.title = post.title
        self.content = post.content
        self.createdAt = post.createdAt
        self.updatedAt = post.updatedAt
        self.authorId = post.$author.id
        self.excerpt = post.excerpt
        self.status = post.status

        if let user = post.$author.value {
            self.author = OutUser(user: user)
        } else {
            self.author = nil
        }
    }
}
