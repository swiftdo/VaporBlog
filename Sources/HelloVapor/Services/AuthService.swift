// 提供认证需要的服务提供给 controller 调用
import Vapor
import Fluent

protocol AuthService {

    func login(input: InLogin, request: Request) async throws -> OutLogin

    func register(input: InRegister, db: any Database,  request: Request) async throws -> OutLogin
    

    func refreshToken(input: InRefreshToken, request: Request) async throws -> OutLogin

}