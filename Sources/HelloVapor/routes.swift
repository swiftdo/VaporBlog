import Vapor




/// 定义路由
func routes(_ app: Application) throws {
    // 默认的根路由
    app.get { req in
        return "Hello, world!"
    }

    // MARK-API控制器
    try app.group("api") { api in
        try api.group("v1") { v1 in
            try v1.register(collection: PostController())
        }
    }

    // MARK-页面控制器
    try app.group("page") { page in
        try page.register(collection: PostPageController())
    }

}
