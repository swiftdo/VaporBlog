struct OutLogin: Out {
    let token: String
    let refreshToken: String

    let user: OutUser

    init(token: String, refreshToken: String, user: OutUser) {
        self.token = token
        self.refreshToken = refreshToken
        self.user = user
    }
}