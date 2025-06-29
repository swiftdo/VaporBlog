import Vapor 
import Fluent


struct SeedInitialTag: AsyncMigration { 
    let initialTags = [
        "Swift",
        "Vapor",
        "Fluent",
        "Async/Await",
        "Python",
        "JavaScript",
        "Flutter",
        "Dart",
        "Java",
        "Kotlin",
        "Go",
        "Rust"
    ]

    // 添加
    func prepare(on database: any Database) async throws {
        // 创建初始标签
        try await database.transaction { db in
            for tagName in initialTags {
                let tag = Tag(name: tagName)
                try await tag.save(on: db)
            }
        }
    }

    func revert(on database: any Database) async throws {
        // 删除 initialTags 标签
        try await database.transaction { db in
            for tagName in initialTags {
                try await Tag.query(on: db)
                    .filter(\.$name == tagName)
                    .delete()
            }
        }
    }
}

