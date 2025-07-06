import Vapor

import Fluent // 导入 Fluent 核心
import FluentPostgresDriver // 导入 PostgreSQL 驱动
import Leaf // 导入 Leaf 模板引擎


// configures your application
public func configure(_ app: Application) async throws {
    guard let jwtSec = Environment.get("JWT_SECRET") else {
        fatalError("Missing JWT_SECRET environment variable.")
    }
    
    await app.jwt.keys.add(hmac: .init(from: jwtSec), digestAlgorithm: .sha256)

    // MARK: - 静态文件中间件（用于 Leaf 模板加载 CSS/JS）
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    // MARK: -自定义错误中间件
    app.middleware.use(APIErrorMiddleware())
    

    // MARK: - 注册 Leaf 模板引擎
    app.views.use(.leaf)
    app.leaf.tags["flash"] = FlashTag()
    app.leaf.tags["relativeDate"] = RelativeDateTag()
    
    // MARK: - 注册数据库
    try databases(app)
    
    // MARK: - 注册路由
    try routes(app)
    
    // MARK: - 注册 Fluent 迁移
    try migrations(app)

    // MARK: - 配置 email smtp 
    try emails(app)
    
    // MARK: - 执行迁移, 正式环境由外部环境设置
    if app.environment != .production {
        try await app.autoMigrate();
    }
}

// Mark: - 邮件配置
private func emails(_ app: Application) throws {
    app.email = EmailServiceImpl(app: app)
}

// 将迁移配置分离到单独方法
private func migrations(_ app: Application) throws {
    app.migrations.add(CreatePost())
    app.migrations.add(CreateUser())
    app.migrations.add(CreateUserAuth())
    app.migrations.add(CreateRefreshToken())
    app.migrations.add(CreateEmailVerifyCode())
    
    app.migrations.add(AddFilesToPost())
    app.migrations.add(CreateCategory())
    app.migrations.add(CreatePostCategory())
    app.migrations.add(CreateTag())
    app.migrations.add(CreatePostTag())
    app.migrations.add(CreateComment())

    // 添加初始数据迁移
    app.migrations.add(SeedInitialTag())
    app.migrations.add(SeedInitialCategory())
}

// 数据库配置
private func databases(_ app: Application) throws {
    // 从环境变量中获取数据库连接信息
    // Vapor 的 app.environment 会自动加载 .env 文件中的变量（在开发模式下）
    guard let dbHost = Environment.get("DATABASE_HOST") else {
        fatalError("Missing DATABASE_HOST environment variable.")
    }
    guard let dbPortString = Environment.get("DATABASE_PORT"),
          let dbPort = Int(dbPortString) else {
        fatalError("Missing or invalid DATABASE_PORT environment variable.")
    }
    guard let dbUsername = Environment.get("DATABASE_USERNAME") else {
        fatalError("Missing DATABASE_USERNAME environment variable.")
    }
    guard let dbPassword = Environment.get("DATABASE_PASSWORD") else {
        fatalError("Missing DATABASE_PASSWORD environment variable.")
    }
    guard let dbName = Environment.get("DATABASE_NAME") else {
        fatalError("Missing DATABASE_NAME environment variable.")
    }
    
    // 为应用注册 PostgreSQL 数据库，使用从 .env 读取的变量
    app.databases.use(
        .postgres(configuration: .init(
            hostname: dbHost, // Docker 容器在本地主机上运行
            port: dbPort,
            username: dbUsername, // Docker 启动时设置的用户名
            password: dbPassword, // Docker 启动时设置的密码
            database: dbName, // Docker 启动时创建的数据库名
            tls: .disable)
        ),
        as: .psql
    )
}
