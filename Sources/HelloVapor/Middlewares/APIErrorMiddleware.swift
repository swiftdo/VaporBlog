//
//  ApiErrorMiddleware.swift
//  HelloVapor
//
//  Created by laijihua on 2025/6/5.
//
import Vapor

final class APIErrorMiddleware: AsyncMiddleware {
    private let logger: Logger
    
    init(logger: Logger = Logger(label: "APIErrorMiddleware")) {
        self.logger = logger
    }
    
    func respond(to request: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        do {
            return try await next.respond(to: request)
        } catch {
            let response: OutStatus
            let status: HTTPStatus
            
            switch error {
            case let apiError as APIError:
                response = apiError.res
                status = apiError.status
            case let abort as Abort:
                response = .init(code: Int(abort.status.code), message: abort.reason)
                status = abort.status
            default:
                response = .init(code: 500, message:  String(describing: error))
                status = .internalServerError
            }
            request.logger.report(error: error)
            return try await APIResponse<OutEmpty>(error: response).encodeResponse(status: status, for: request)
        }
    }
}
