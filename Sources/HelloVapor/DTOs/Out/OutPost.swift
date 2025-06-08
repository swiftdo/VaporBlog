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

    // 专业推荐：DTO 层负责转换，解耦模型
    init(from post: Post) {
        self.id = post.id!
        self.title = post.title
        self.content = post.content
        self.createdAt = post.createdAt
        self.updatedAt = post.updatedAt
    }
}
