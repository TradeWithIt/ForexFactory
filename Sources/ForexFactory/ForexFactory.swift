import Foundation

public enum Impact: String, Decodable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}

public struct ForexEvent: Decodable {
    public let title: String
    public let country: String
    public let date: String
    public let impact: Impact
    public let forecast: String?
    public let previous: String?
    public let actual: String?
    public let timestamp: Int
}

public struct ForexCalendar: Decodable {
    public let events: [ForexEvent]
}

public extension [ForexEvent] {
    func eventsForToday() -> [ForexEvent] {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: today)
        
        return self.filter { $0.date.contains(todayString) }
    }
    
    func events(withImpact impact: Impact = .high) -> [ForexEvent] {
        return self.filter { $0.impact == impact }
    }
    
    func events(by country: String = "USD") -> [ForexEvent] {
        return self.filter { $0.country == country }
    }
    
}

public final class ForexAPI {
    public let baseUrl = URL(string: "https://nfs.faireconomy.media/ff_calendar_thisweek.json")!

    public func fetchEvents() async throws -> [ForexEvent] {
        let (data, _) = try await URLSession.shared.data(from: baseUrl)
        let calendar = try JSONDecoder().decode(ForexCalendar.self, from: data)
        return calendar.events
    }
}
