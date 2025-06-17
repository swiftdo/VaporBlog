import Vapor 

protocol EmailService: Sendable {
    // 给某某发送一封邮件，主题是 subject，内容是 body
    func send(subject: String, body: String, to email: String, isBodyHtml: Bool, on request: Request) async throws
}

struct EmailServiceKey: StorageKey {
    typealias Value = EmailService
}

extension Application {
    var email: any EmailService {
        get {
            guard let service = self.storage[EmailServiceKey.self] else {
                fatalError("Email service not registered")
            }
            return service
        }
        set {
            self.storage[EmailServiceKey.self] = newValue
        }
    }
}
extension Request {
    func sendEmail(subject: String, body: String, to email: String, isBodyHtml: Bool = false,) async throws {
        try await self.application.email.send(subject: subject, body: body, to: email, isBodyHtml: isBodyHtml,  on: self)
    }
}
