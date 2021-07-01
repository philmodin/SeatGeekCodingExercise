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
//                return "______ _____ _ ____"
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
//                return "____ __"
                return "no time"
            }
        }
        
        let venue: Venue?
        struct Venue: Codable, Identifiable {
            let id: Int
            let name: String
            let state: String?
            let city: String?
            
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
    }
    
    struct Meta: Codable {
        let total: Int
        let page: Int
    }
}
