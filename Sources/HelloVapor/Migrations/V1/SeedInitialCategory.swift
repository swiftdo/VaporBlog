import Vapor
import Fluent


struct SeedInitialCategory: AsyncMigration { 
    let initialCategories = [
        "编程语言",
        "前端开发",
        "后端开发",
        "移动开发",
        "全栈开发",
        "数据库",
        "算法",
        "设计模式",
        "人工智能",
        "随笔",
        "书籍推荐"
    ]

    // 添加
    func prepare(on database: any Database) async throws {
        // 创建初始分类
        try await database.transaction { db in
            for categoryName in initialCategories {
                let category = Category(name: categoryName)
                try await category.save(on: db)
            }
        }
    }

    func revert(on database: any Database) async throws {
        // 删除 initialCategories 分类
        try await database.transaction { db in
            for categoryName in initialCategories {
                try await Category.query(on: db)
                    .filter(\.$name == categoryName)
                    .delete()
            }
        }
    }


}