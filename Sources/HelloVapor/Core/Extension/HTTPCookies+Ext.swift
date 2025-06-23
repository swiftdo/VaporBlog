import Vapor 
extension HTTPCookies {
    mutating func set(key: Constants.CookieKeys, value: HTTPCookies.Value) {
        self[key.rawValue] = value
    }

    func get(key: Constants.CookieKeys) -> HTTPCookies.Value? {
        return self[key.rawValue]
    }

    mutating func expired(key: Constants.CookieKeys) {
        self[key.rawValue] = .expired
    }
}