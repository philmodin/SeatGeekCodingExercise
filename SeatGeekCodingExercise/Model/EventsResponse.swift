//  EventsResponse.swift
//  SeatGeekCodingExercise
//  Created by endOfLine on 6/26/21.

import MapKit

struct EventsResponse: Codable {
    
    let events: [Event]
    let meta: Meta
    
    struct Events: Codable, Identifiable {
        let id: Int
        let title: String
        let short_title: String
        let datetime_local: String
        
        let venue: Venue?
        struct Venue: Codable, Identifiable {
            let id: Int
            let name: String
            let state: String
            let city: String
            
            let location: Location
            struct Location: Codable {
                let lat: Double
                let lon: Double
            }
            var coordinates: CLLocationCoordinate2D {
                CLLocationCoordinate2D(latitude: location.lat, longitude: location.lon)
            }
        }
        
        let performers: [Performer]
        struct Performer: Codable {
            let image: String?
            var imageURL: URL? {
                if let imageString = image {
                    return URL(string: imageString)
                } else {
                    return nil
                }
            }
        }
    }
    
    struct Meta: Codable {
        let total: Int
        let page: Int
    }
}
