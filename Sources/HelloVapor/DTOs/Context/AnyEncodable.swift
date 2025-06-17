struct AnyEncodable: Encodable {
    let value: any Encodable

    func encode(to encoder: any Encoder) throws {
        try value.encode(to: encoder)
    }
}