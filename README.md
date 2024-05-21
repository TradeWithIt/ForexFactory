# Forex API SDK

The Forex API SDK is a Swift package designed to interact with the Forex Factory's weekly calendar. It enables users to fetch financial event data and filter these events by various criteria including date, impact level, and country. All data is sourced from Forex Factory.

## Features

- Fetch this week's financial events from Forex Factory.
- Filter events occurring today.
- Filter events based on their impact level (High, Medium, Low).
- Filter events by country.

## Requirements

- iOS 17.0+ / macOS 14+
- Swift 5.5+
- Xcode 12.0+

## Installation

Include the SDK in your Swift project by adding the source files directly to your project or using a dependency manager like Swift Package Manager.

## Usage

### Fetching Events

To fetch all the events for the current week:

```swift
import YourSDK

let api = ForexAPI()
Task {
    do {
        let events = try await api.fetchEvents()
        print("Fetched events: \(events)")
    } catch {
        print("Error fetching events: \(error)")
    }
}
```

### Filtering Events

#### Events For Today

To get all events for today:

```swift
let todayEvents = events.eventsForToday()
print("Today's events: \(todayEvents)")
```

#### Events by Impact

To filter events by impact level:

```swift
let highImpactEvents = events.events(withImpact: .high)
print("High impact events: \(highImpactEvents)")
```

#### Events by Country

To filter events by a specific country (e.g., USD):

```swift
let usEvents = events.events(by: "USD")
print("Events in the US: \(usEvents)")
```

## Credits and Acknowledgements

This SDK utilizes financial events data provided by Forex Factory. For more information about Forex Factory and the services they offer, visit their website: [www.forexfactory.com](http://www.forexfactory.com).

## Contributing

Contributions are welcome. Please fork the repository and submit a pull request with your changes.

## License

This SDK is distributed under the MIT License. See `LICENSE` for more information.
