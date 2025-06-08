//
//  PostControllerTests.swift
//  HelloVapor
//
//  Created by laijihua on 2025/6/7.
//
@testable import HelloVapor
import VaporTesting
import Testing
import Fluent
import FluentPostgresDriver


@Suite("PostController Tests", .serialized)
struct PostControllerTests {
    
    private func withApp(_ closure: (Application) async throws -> ()) async throws {
        let app = try await Application.make(.testing)
        do {
            try await configure(app)
            try await closure(app)
            try await app.autoRevert() // 撤回修改
        }
        catch {
            try? await app.autoRevert()
            try await app.asyncShutdown()
            throw error
        }
        try await app.asyncShutdown()
    }
    
    @Test("创建帖子 - 正常情况")
    func testCreatePost() async throws {
        try await withApp { app in
            let inPost = InPost(title: "Test Title", content: "Test Content")
            try await app.test(.POST, "posts",
                               beforeRequest: { req in try req.content.encode(inPost) },
                               afterResponse: { res async throws in
                #expect(res.status == .ok)
                let postRes = try res.content.decode(APIResponse<OutPost>.self)
                let post = postRes.data!
                #expect(post.title == inPost.title)
            })
        }
    }

    @Test("创建帖子 - 空标题")
    func testCreatePostWithEmptyTitle() async throws {
        try await withApp { app in
            let inPost = InPost(title: "", content: "Content")
            try await app.test(.POST, "posts",
                                             
                               beforeRequest: { req in try req.content.encode(inPost) },
                               afterResponse: { res async throws in
                #expect(res.status == .internalServerError)
            })
        }
    }

    @Test("获取所有帖子")
    func testGetAllPosts() async throws {
        try await withApp { app in
            let post1 = Post(title: "Post A", content: "Content A")
            try await post1.save(on: app.db)
            try await app.test(.GET, "posts") { res async throws in
                #expect(res.status == .ok)
                let postsRes = try res.content.decode(APIResponse<[OutPost]>.self)
                let posts = postsRes.data!
                #expect(posts.count == 1)
            }
        }
    }

    @Test("获取单篇帖子 - 正常情况")
    func testGetSinglePost() async throws {
        try await withApp { app in
            let post = Post(title: "Single Post", content: "Single Content")
            try await post.save(on: app.db)
            try await app.test(.GET, "posts/\(post.id!)") { res async throws in
                #expect(res.status == .ok)
                let receivedRes = try res.content.decode(APIResponse<OutPost>.self)
                let received = receivedRes.data!
                #expect(received.id == post.id)
            }
        }
    }

    @Test("获取单篇帖子 - 无效ID")
    func testGetSinglePostWithInvalidId() async throws {
        try await withApp { app in
            try await app.test(.GET,
                               "posts/\(UUID())",
                               afterResponse: { res async throws in
                #expect(res.status == .notFound)
            })
        }
    }

    @Test("更新帖子")
    func testUpdatePost() async throws {
        try await withApp { app in
            let post = Post(title: "Old Title", content: "Old Content")
            try await post.save(on: app.db)
            let updatedPost = InPost(title: "New Title", content: "New Content")
            try await app.test(.PUT, "posts/\(post.id!)",
                               beforeRequest: { req in try req.content.encode(updatedPost) },
                               afterResponse: { res async throws in
                #expect(res.status == .ok)
                let updatedRes = try res.content.decode(APIResponse<OutPost>.self)
                let updated = updatedRes.data!
                #expect(updated.title == "New Title")
            })
        }
    }

    @Test("删除帖子")
    func testDeletePost() async throws {
        try await withApp { app in
            let post = Post(title: "To Delete", content: "Content")
            try await post.save(on: app.db)
            try await app.test(.DELETE, "posts/\(post.id!)") { res async throws in
                #expect(res.status == .ok)
                let count = try await Post.query(on: app.db).count()
                #expect(count == 0)
            }
        }
    
   }

    @Test("删除帖子 - 无效ID")
    func testDeletePostWithInvalidId() async throws {
        try await withApp { app in
           try await app.test(.DELETE, "posts/\(UUID())", afterResponse: { res async throws in
                #expect(res.status == .notFound)
            }
         )
        }
    }
}

