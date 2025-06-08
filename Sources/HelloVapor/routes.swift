import Vapor




/// 定义路由
func routes(_ app: Application) throws {
    // 默认的根路由
    app.get { req in
        return "Hello, world!"
    }

    try app.register(collection: PostController())

}
