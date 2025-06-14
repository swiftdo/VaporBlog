import Smtp
import Vapor

final class EmailServiceImpl: EmailService {

    init(app: Application) {
        guard let smtpHost = Environment.get("SMTP_HOST") else {
            fatalError("Missing SMTP_HOST environment variable.")
        }
        guard let smtpPortStr = Environment.get("SMTP_PORT"),
            let smtpPort = Int(smtpPortStr) else {
            fatalError("Missing or invalid SMTP_PORT environment variable.")
        }
        guard let smtpUserName = Environment.get("SMTP_USERNAME") else {
            fatalError("Missing SMTP_USERNAME environment variable.")
        }
        guard let smtpPassword = Environment.get("SMTP_PASSWORD") else {
            fatalError("Missing SMTP_PASSWORD environment variable.")
        }
        // 获取 SMTP 配置
        app.smtp.configuration = SmtpServerConfiguration(
            hostname: smtpHost, 
            port: smtpPort, 
            signInMethod: .credentials(username: smtpUserName, password: smtpPassword), 
            secure: .ssl, 
        )
    }


    func send(subject: String, body: String, to email: String, isBodyHtml: Bool, on request: Request) async throws {
        let smtpUserName = Environment.get("SMTP_USERNAME") ?? ""

        let email = try Email(
            from: EmailAddress(address: smtpUserName, name: "VaporBlog"),
            to: [EmailAddress(address: email)],
            subject: subject,
            body: body, 
            isBodyHtml: isBodyHtml)
        try await request.smtp.send(email)
    }
}



