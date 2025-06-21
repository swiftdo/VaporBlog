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
        // 站点域名
        guard let value = Environment.get("SITE_DOMAIN") else {
            fatalError("Missing SITE_DOMAIN environment variable.")
        }
        return value;
    }

    static func GITHUB_CLIENT_ID() -> String {
        // github 应用 id 
        guard let value = Environment.get("GITHUB_CLIENT_ID") else {
            fatalError("Missing GITHUB_CLIENT_ID environment variable.")
        }
        return value;
    }

    static func GITHUB_CALLBACK_URL() -> String {
        // github 回调地址
        guard let value = Environment.get("GITHUB_CALLBACK_URL") else {
            fatalError("Missing GITHUB_CALLBACK_URL environment variable.")
        }
        return value;
    }

    static func GITHUB_CLIENT_SECRET() -> String {
        // github 应用密钥
        guard let value = Environment.get("GITHUB_CLIENT_SECRET") else {
            fatalError("Missing GITHUB_CLIENT_SECRET environment variable.")
        }
        return value;
    }
}