import LeafKit
import Foundation

struct RelativeDateTag: LeafTag {
    func render(_ ctx: LeafContext) throws -> LeafData {    
        guard let dateAsDouble = ctx.parameters.first?.double else {
            throw LeafError(.unknownError("Unable to convert parameter to double for date"))
        }
        let date = Date(timeIntervalSince1970: dateAsDouble)

        let components = Calendar.current.dateComponents([.minute, .hour, .day, .weekOfYear], from: date, to: Date())

        if let week = components.weekOfYear, week > 0 {
            // 超过一周显示具体日期
            let formatter = DateFormatter()
            formatter.dateStyle = .medium // 例如：2025年7月5日
            formatter.locale = Locale(identifier: "zh_CN")
            return .string(formatter.string(from: date))
        } else if let day = components.day, day > 0 {
            return .string("\(day)天前")
        } else if let hour = components.hour, hour > 0 {
            return .string("\(hour)小时前")
        } else if let minute = components.minute, minute > 0 {
            return .string("\(minute)分钟前")
        } else {
            return .string("刚刚")
        }
    }
}