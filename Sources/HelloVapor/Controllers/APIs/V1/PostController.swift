//
//  PostController.swift
//  HelloVapor
//
//  Created by laijihua on 2025/6/6.
//

import Vapor
import Fluent

struct PostController: RouteCollection, @unchecked Sendable {
    let postService: any PostService

    init(postService: any PostService) {
        self.postService = postService
    }

    func boot(routes: any RoutesBuilder) throws {
        let posts = routes.grouped("posts")

        // 需要登录才能进行访问
        let secure = posts.grouped(UserPayload.authenticator(), UserPayload.guardMiddleware())
        posts.get(use: index)

        secure.post(use: create)
        posts.group(":postID") { post in
            post.get(use: show)
            let postSecure = post.grouped(UserPayload.authenticator(), UserPayload.guardMiddleware())
            postSecure.put(use: update)
            postSecure.delete(use: delete)
        }
    }


    // 看所有文章
    func index(req: Request) async throws -> APIResponse<Page<OutPost>> {
        let paged = try await postService.list(req: req)
        return APIResponse(success: paged)
    }

    // 新建文章
    func create(req: Request) async throws -> APIResponse<OutPost> {
        let userPayload = try req.auth.require(UserPayload.self)
        guard let user = try await User.find(userPayload.userId, on: req.db) else {
            throw APIError.notFound(msg: "用户不存在")
        }
        try InPost.validate(content: req)
        let input = try req.content.decode(InPost.self)
        let outPost = try await postService.create(input: input, userId: user.requireID(), req: req)
        return APIResponse(success: outPost)
    }

    // 查看单篇
    func show(req: Request) async throws -> APIResponse<OutPost> {
        guard let postId = req.parameters.get("postID"),
            let uuid = UUID(uuidString: postId),
            let post = try await postService.detail(postId: uuid, req: req) else {
            throw APIError.notFound(msg: "文章不存在")
        }
        return APIResponse(success: post)
    }

    // 修改
    func update(req: Request) async throws -> APIResponse<OutPost> {
        guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
            throw APIError.notFound(msg: "文章不存在")
        }
        try InPost.validate(content: req)
        let input = try req.content.decode(InPost.self)
        let output = try await postService.update(input: input, post: post, req: req)
        return APIResponse(success: output)
    }

    // 删除
    func delete(req: Request) async throws -> APIResponse<OutEmpty> {
        guard let post = try await Post.find(req.parameters.get("postID"), on: req.db) else {
            throw APIError.notFound(msg: "文章不存在")
        }
        try await postService.delete(post: post, req: req)
        return OutEmpty.ok(msg: "删除成功")
    }
}
