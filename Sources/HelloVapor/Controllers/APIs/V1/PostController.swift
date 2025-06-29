//
//  PostController.swift
//  HelloVapor
//
//  Created by laijihua on 2025/6/6.
//

import Vapor
import Fluent

struct PostController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let posts = routes.grouped("posts")
        posts.get(use: index)

        // posts.post(use: create)
        posts.group(":postID") { post in
            post.get(use: show)
            post.put(use: update)
            post.delete(use: delete)
        }
    }

    // 看所有文章
    func index(req: Request) async throws -> APIResponse<[OutPost]> {
        let posts = try await Post.query(on: req.db).all()
        let out = posts.map { OutPost(from: $0) }
        return APIResponse(success: out)
    }

    // 新建文章
    // func create(req: Request) async throws -> APIResponse<OutPost> {
    //     try InPost.validate(content: req)
    //     let input = try req.content.decode(InPost.self)
    //     let post = Post(title: input.title, content: input.content)
    //     try await post.create(on: req.db)
    //     return APIResponse(success: OutPost(from: post))
    // }

    // 查看单篇
    func show(req: Request) async throws -> APIResponse<OutPost> {
        guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
            throw APIError.notFound(msg: "文章不存在")
        }
        return APIResponse(success: OutPost(from: post))
    }

    // 修改
    func update(req: Request) async throws -> APIResponse<OutPost> {
        guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
            throw APIError.notFound(msg: "文章不存在")
        }
        try InPost.validate(content: req)
        let input = try req.content.decode(InPost.self)
        post.title = input.title
        post.content = input.content
        try await post.update(on: req.db)
        return APIResponse(success: OutPost(from: post))
    }

    // 删除
    func delete(req: Request) async throws -> APIResponse<OutEmpty> {
        guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
            throw APIError.notFound(msg: "文章不存在")
        }
        try await post.delete(on: req.db)
        return OutEmpty.ok(msg: "删除成功")
    }
}
