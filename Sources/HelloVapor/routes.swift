import Vapor

/// 定义路由
func routes(_ app: Application) throws {
    // 默认的根路由
    app.get { req in
        return req.view.render("me")
    }

    app.get("email") { req async throws in
        do {
            try await req.sendEmail(subject: "The subject (text2)", body: "This is email body2.", to: "oheroj@gmail.com", isBodyHtml: false)
        } catch {
            return "Error sending email."
        }
        return "Email sent."
    }

    let authService: any AuthService = AuthServiceImpl()

    // MARK-API控制器
    try app.group("api") { api in
        try api.group("v1") { v1 in
            try v1.register(collection: PostController())
            try v1.register(collection: AuthController(authService: authService))
            try v1.register(collection: UserController())
        }
    }

    // MARK-页面控制器
    try app.grouped(app.sessions.middleware).group("page") { page in
        try page.register(collection: PostPageController())
        try page.register(collection: AuthPageController(authService: authService))
    }

}
