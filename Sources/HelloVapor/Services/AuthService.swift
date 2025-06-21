// 提供认证需要的服务提供给 controller 调用
import Vapor
import Fluent

protocol AuthService {
    /// 登录
    /// - Parameters:
    ///     - input: 登录参数
    /// - Returns: OutLogin
    func login(input: InLogin, request: Request) async throws -> OutLogin

    /// 注册
    func register(input: InRegister, activePath: String, db: any Database,  request: Request) async throws -> OutLogin
    
    /// 刷新 token
    func refreshToken(input: InRefreshToken, request: Request) async throws -> OutLogin

    /// 登出
    func logout(request: Request) async throws -> Void

    /// 激活
    func activate(input: InActive, request: Request) async throws -> Void

    /// 生成 token
    func generateAuthTokens(for user: User, on db: any Database, req: Request) async throws -> OutLogin
}