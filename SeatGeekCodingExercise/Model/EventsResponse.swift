//  EventsResponse.swift
//  SeatGeekCodingExercise
//  Created by endOfLine on 6/26/21.

import MapKit

struct EventsResponse: Codable {
    
    let events: [Event]
    let meta: Meta
    
    struct Event: Codable, Identifiable {
        let id: Int
        let title: String
        let short_title: String
        let datetime_local: String
        let url: String
        // calculate Date from datetime_local
        var date: Date? {
            let RFC3339DateFormatter = DateFormatter()
            RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
            RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            if let date = RFC3339DateFormatter.date(from: datetime_local) {
                return date
            } else {
                return nil
            }
        }
        // format date into a day string "Tuesday, June 29, 2021"
        var day: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            dateFormatter.timeStyle = .none
            if let day = date {
                return dateFormatter.string(from: day)
            } else {
                return "no date"
            }
        }
        // format date into a time string "8:30 PM"
        var time: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            if let day = date {
                return dateFormatter.string(from: day)
            } else {
                return "no time"
            }
        }
        
        let venue: Venue?
        struct Venue: Codable, Identifiable {
            let id: Int
            let name: String
            let state: String?
            let city: String?
            let display_location: String
            
            let location: Location
            struct Location: Codable {
                let lat: Double
                let lon: Double
            }
            var coordinates: CLLocationCoordinate2D {
                CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
            }
        }
        
        let performers: [Performer?]
        struct Performer: Codable, Identifiable {
            let id: Int
            let image: String?
            var imageURL: URL? {
                if let imageString = image {
                    return URL(string: imageString)
                } else {
                    return nil
                }
            }
            let taxonomies: [Taxonomy?]
            struct Taxonomy: Codable, Identifiable {
                let id: Int
                let parent_id: Int?
                let name: String
            }
        }
        
        let stats: Stats
        struct Stats: Codable {
            let lowest_price: Int?
            let highest_price: Int?
        }
    }
    
    struct Meta: Codable {
        let total: Int
        let page: Int
    }
    
    static let sampleEventPass = Event(
        id: 1,
        title: "UEFA Euro Cup Quarterfinals: QF1",
        short_title: "UEFA Euro Cup Quarterfinals: QF1",
        datetime_local: "2021-07-02T03:30:00",
        url: "https://seatgeek.com/uefa-euro-cup-quarterfinals-qf3-tickets/soccer/2021-07-03-3-30-am/5052051",
        venue: Event.Venue(
            id: 419762,
            name: "Krestovsky Stadium",
            state: nil,
            city: "Saint Petersburg",
            display_location: "Saint Petersburg, Russia",
            location: Event.Venue.Location(lat: 59.9711, lon: 30.245)
        ),
        performers: [Event.Performer(
                        id: 37452,
                        image: "https://seatgeek.com/images/performers-landscape/generic-soccer-4e2b58/677196/32408/huge.jpg",
                        taxonomies: []
        )],
        stats: EventsResponse.Event.Stats(
            lowest_price: 177,
            highest_price: 218
        )
    )
    
    static let sampleEventFail = Event(
        id: 0,
        title: "UEFA Euro Cup Quarterfinals: QF1",
        short_title: "UEFA Euro Cup Quarterfinals: QF1",
        datetime_local: "Invalid",
        url: "Invalid UrL",
        venue: Event.Venue(
            id: 419762,
            name: "Krestovsky Stadium",
            state: nil,
            city: "Saint Petersburg",
            display_location: "Saint Petersburg, Russia",
            location: Event.Venue.Location(lat: 59.9711, lon: 30.245)
        ),
        performers: [Event.Performer(
                        id: 37452,
                        image: nil,
                        taxonomies: []
        )],
        stats: EventsResponse.Event.Stats(
            lowest_price: 177,
            highest_price: 218
        )
    )
}
