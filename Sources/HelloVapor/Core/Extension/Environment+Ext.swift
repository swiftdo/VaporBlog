import Vapor 

extension Environment {

    static func ACCESS_TOKEN_EXPIRE() -> TimeInterval{
        let data = Environment.get("ACCESS_TOKEN_EXPIRE_TIME")
        if let data, let time = TimeInterval(data) {
            return time
        }
        return 3600
    }

    static func REFRESH_TOKEN_EXPIRE() -> TimeInterval{
        let data = Environment.get("REFRESH_TOKEN_EXPIRE_TIME")
        if let data, let time = TimeInterval(data) {
            return time
        }
        return 86400
    }

    static func SITE_DOMAIN() -> String {
        return Environment.get("SITE_DOMAIN") ?? "http://localhost:8080"
    }
}