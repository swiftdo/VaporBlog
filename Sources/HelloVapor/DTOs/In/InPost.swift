//
//  InPost.swift
//  HelloVapor
//
//  Created by laijihua on 2025/6/6.
//

import Vapor

struct InPost: In, Validatable {
    let title: String
    let content: String
    let excerpt: String? // 概要
    let status: Post.Status? // 文章状态

    let categoryIds: String? // 文章分类 IDs, ","分割
    let tagIds: String? // 文章标签 IDs, "," 分割

    static func validations(_ validations: inout Validations) {
        validations.add("title", as: String.self, is: .count(1...), customFailureDescription: "标题不能为空")
        validations.add("content", as: String.self, is: .count(1...), customFailureDescription: "内容不能为空")
    }
}
