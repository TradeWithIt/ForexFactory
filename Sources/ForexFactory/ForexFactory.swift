import Foundation

public enum Impact: String, Sendable, Codable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    case other

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        self = Impact(rawValue: rawValue) ?? .other
    }
}

public struct ForexEvent: Sendable, Codable {
    public let id = UUID()
    public let title: String
    public let country: String
    public let date: Date
    public let impact: Impact
    public let forecast: String?
    public let previous: String?
    public let actual: String?
    
    public enum CodingKeys: CodingKey {
        case title
        case country
        case date
        case impact
        case forecast
        case previous
        case actual
    }
}

public struct ForexCalendar: Decodable {
    public let events: [ForexEvent]
}

public extension [ForexEvent] {
    func eventsForToday() -> [ForexEvent] {
        let today = Date()
        let calendar = Calendar.current
        
        return self.filter { event in
            calendar.isDate(event.date, inSameDayAs: today)
        }
    }
    
    func events(withImpact impact: Impact = .high) -> [ForexEvent] {
        return self.filter { $0.impact == impact }
    }
    
    func events(by country: String = "USD") -> [ForexEvent] {
        return self.filter { $0.country == country }
    }
    
}

public final class ForexAPI {
    public enum Error: Swift.Error {
        case wrongResponseType
        case failed(status: Int, message: String)
    }
    private static let baseUrl = URL(string: "https://nfs.faireconomy.media/ff_calendar_thisweek.json")!

    public static func fetchEvents() async throws -> [ForexEvent] {
        let (data, response) = try await URLSession.shared.data(from: baseUrl)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw Error.wrongResponseType
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            throw Error.failed(status: httpResponse.statusCode, message: String(data: data, encoding: .utf8) ?? "")
        }
        let events = try jsonDecoder.decode([ForexEvent].self, from: data)
        return events
    }
}


// MARK: - Helpers

private let customDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "h:mm MM/dd/yy"
    return formatter
}()


private let iso8601DateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return formatter
}()

private let iso8601DateOnlyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

private let iso8601DateMillisecondsFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: Calendar.Identifier.iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    return formatter
}()

private let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.nonConformingFloatDecodingStrategy = .convertFromString(
        positiveInfinity: "Infinity",
        negativeInfinity: "-Infinity",
        nan: "NaN"
    )
    decoder.dateDecodingStrategy = .custom({ decoder in
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        if let date = iso8601DateFormatter.date(from: value) {
            return date
        }
        if let date = iso8601DateMillisecondsFormatter.date(from: value) {
            return date
        }
        if let date = iso8601DateOnlyFormatter.date(from: value) {
            return date
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(value)")
    })
    return decoder
}()
