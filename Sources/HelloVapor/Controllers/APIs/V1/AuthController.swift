import Vapor
import Fluent

struct AuthController: RouteCollection { 
    func boot(routes: any RoutesBuilder) throws {

        let authRoutes = routes.grouped("api", "auth")

        // authRoutes.post("register", use: register)
        // authRoutes.post("login", use: login)
        // authRoutes.post("resetpwd", use: resetPwd)


        // 需要登录才能进行访问
        // authRoutes.post("logout", use: logout)
        // authRoutes.post("refresh", use: refresh)
        // authRoutes.get("me", use: me)
        // authRoutes.post("changepwd", use: changePwd)
    
    }



}

