import LeafKit

struct FirstLetterTag: LeafTag {
    func render(_ ctx: LeafContext) throws -> LeafData {
        guard let string = ctx.parameters.first?.string else {
            throw "FirstLetterTag requires a string parameter."
        }
        return .string(String(string.prefix(1)))
    }
}
