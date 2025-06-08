//
//  Out.swift
//  HelloVapor
//
//  Created by laijihua on 2025/6/5.
//
import Vapor

protocol Out: Content {}

extension Int: Out {}

extension Array : Out where Element: Out {}

protocol APIRespondable {
    var code: Int { get }
    var message: String { get }
}

// 业务层错误信息
struct OutStatus: Out, APIRespondable {
    var code: Int
    var message: String

    init(code: Int, message: String) {
        self.code = code
        self.message = message
    }
}


// MARK: - 统一响应结构
struct APIResponse<T: Out>: Out, APIRespondable {
    var code: Int
    var message: String
    var data: T?

    init(code: Int = 0, message: String = "请求成功", data: T? = nil) {
        self.code = code
        self.message = message
        self.data = data
    }

    init(code: OutStatus, data: T? = nil) {
        self.code = code.code
        self.message = code.message
        self.data = data
    }

    init(success data: T) {
        self.init(code: OutStatus(code: 200, message: "请求成功"), data: data)
    }

    init(error code: OutStatus) {
        self.init(code: code)
    }
}


struct OutEmpty: Out {
    static func ok(msg: String = "请求成功") -> APIResponse<OutEmpty> {
        return APIResponse<OutEmpty>(success: OutEmpty());
    }
}

// 统一错误
enum APIError : Error {
    case invalidInput(msg: String? = nil)
    case unauthorized(msg: String? = nil)
    case forbidden(msg: String? = nil)
    case notFound(msg: String? = nil)
    case conflict(msg: String? = nil)
    case tooManyRequests(msg: String? = nil)
    case serverError(msg: String? = nil)
    case serviceUnavailable(msg: String? = nil)
    case businessRuleViolation(msg: String? = nil)
    case externalServiceError(msg: String? = nil)
    case custom(code: Int, msg: String? = nil)
    
    var status: HTTPStatus {
        switch self {
        case .invalidInput: return .badRequest
        case .unauthorized: return .unauthorized
        case .forbidden: return .forbidden
        case .notFound: return .notFound
        case .conflict: return .conflict
        case .tooManyRequests: return .tooManyRequests
        case .serverError: return .internalServerError
        case .serviceUnavailable: return .serviceUnavailable
        case .businessRuleViolation: return .badRequest
        case .externalServiceError: return .badGateway
        case .custom: return .badRequest
        }
    }
    
    
    var res: OutStatus {
        var message = ""
        var code: Int = 400
        switch (self) {
        case .invalidInput(let msg):
            message = msg ?? "Invalid input"
            code = 400
        case .unauthorized(let msg):
            message = msg ??  "Unauthorized access"
            code = 401
        case .forbidden(let msg):
            message = msg ?? "Access forbidden"
            code = 403
        case .notFound(let msg):
            message = msg ?? "Resource not found"
            code = 404
        case .conflict(let msg):
            message = msg ?? "Resource conflict"
            code = 409
        case .tooManyRequests(let msg):
            message = msg ?? "Too many requests"
            code = 429
        case .serverError(let msg):
            message = msg ?? "Server error"
            code = 500
        case .serviceUnavailable(let msg):
            message = msg ?? "Service unavailable"
            code = 503
        case .businessRuleViolation(let msg):
            message = msg ?? "Business rule violation"
            code = 400
        case .externalServiceError(let msg):
            message = msg ?? "External service error"
            code = 502
        case .custom(let cd, let msg):
            code = cd
            message = msg ?? "Bad request"
        }
        return OutStatus(code: code, message: message)
    }
    
}




