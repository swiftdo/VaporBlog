import Vapor
import Leaf

// MARK: - Flash Message Storage
struct FlashMessage: Codable {
    let category: String
    let message: String

    enum Category: String {
        case success
        case danger
        case warning
        case info
    }
    
    init(category: Category, message: String) {
        self.category = category.rawValue
        self.message = message
    }

}

// MARK: - Request Extension for Flash Functionality
extension Request {
    func flash(_ category: FlashMessage.Category, message: String) throws {
        // Retrieve existing flash messages from session
        var messages: [FlashMessage] = []
        if let flashData = session.data["flash_messages"],
           let data = flashData.data(using: .utf8),
           let existingMessages = try? JSONDecoder().decode([FlashMessage].self, from: data) {
            messages = existingMessages
        }
        
        // Append new message
        messages.append(FlashMessage(category: category, message: message))
        
        // Save to session
        let data = try JSONEncoder().encode(messages)
        guard let dataString = String(data: data, encoding: .utf8) else {
            throw Abort(.internalServerError, reason: "Failed to encode flash messages")
        }
        session.data["flash_messages"] =  dataString
    }
    
    var flashMessages: [FlashMessage] {
        get throws {
            // Retrieve flash messages from session
            if let flashData = session.data["flash_messages"],
               let data = flashData.data(using: .utf8),
               let messages = try? JSONDecoder().decode([FlashMessage].self, from: data) {
                // Clear flash messages after retrieval
                session.data["flash_messages"] = nil
                return messages
            }
            return []
        }
    }
}

// MARK: - Leaf Tag for Rendering Flash Messages
struct FlashTag: UnsafeUnescapedLeafTag {
    func render(_ ctx: LeafContext) throws -> LeafData {
        guard let req = ctx.request else {
            throw Abort(.internalServerError, reason: "Request not available in Leaf context")
        }
        let messages = try req.flashMessages
        if messages.isEmpty {
            return .string(nil)
        }

        var html = ""

        for message in messages {
            html += """
            <div class="container mt-4">
                <div class="alert alert-\(message.category) alert-dismissible fade show" role="alert">
                    \(message.message)
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </div>
            """
        }
        return .string("""
        <div class="container mt-4">
            \(html)
        </div>
        """)
    }
}