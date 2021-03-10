//
//  SeatGeek.swift
//  FetchRewardsCodingExercise
//
//  Created by endOfLine on 3/9/21.
//

import Foundation

struct Events: Codable {
    var events: [Event]
}

struct Event: Codable {
    var id: Int
    var datetime_utc: String
    var datetime_local: String
    var venue: Venue
    var performers: [Performers]
    var title: String
}

struct Venue: Codable {
    var state: String
    var city: String
}

struct Performers: Codable {
    var image: String
}

struct SeatGeek {
    static let apiBase = "https://api.seatgeek.com/2/events?"
    static let resultsPerPage = 20
    static let dataFormat = "format=json&"
    static var clientID = "MjE1ODMxMzl8MTYxNTI2NTE3Mi4yMjE2MTE3"
    
    static var urlString = "https://api.seatgeek.com/2/events?q=s&per_page=20&page=1&format=json&client_id=MjE1ODMxMzl8MTYxNTI2NTE3Mi4yMjE2MTE3"
    static let decoder = JSONDecoder()

    static func parse(query: String? = nil, pageCursor: Int) -> Events? {
        //print(urlString)
        var search = ""
        if let q = query { search = "q=\(q)&" }
        let urlString = apiBase + search + "per_page=\(resultsPerPage)&" + "page=\(pageCursor)&" + dataFormat + "client_id=\(clientID)"
        //print(urlString)
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                print(data)
                if let jsonEvents = try? decoder.decode(Events.self, from: data) {
                    print("parse: done")
                    return jsonEvents
                }
            }
        }
        return nil
    }
    
    static func dateFrom(rfc: String) -> Date? {
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = RFC3339DateFormatter.date(from: rfc)
        return date
    }
    
    static func stringDayFrom(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    static func stringTimeFrom(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}
