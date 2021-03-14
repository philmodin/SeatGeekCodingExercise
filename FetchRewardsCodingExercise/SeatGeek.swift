//
//  SeatGeek.swift
//  FetchRewardsCodingExercise
//
//  Created by endOfLine on 3/9/21.
//

import Foundation

struct Events: Codable {
    var events: [Event]
    var meta: Meta
}

struct Meta: Codable {
    var total: Int
    var page: Int
    var per_page: Int
}

struct Event: Codable {
    var id: Int
    var datetime_utc: String
    var datetime_local: String
    var venue: Venue?
    var performers: [Performers]
    var title: String
}

struct Venue: Codable {
    var state: String?
    var city: String?
}

struct Performers: Codable {
    var image: String?
}

struct SeatGeek {
    static let apiBase = "https://api.seatgeek.com/2/events?"
    static let sorting = ""//"sort=datetime_local.desc&"
    static let resultsPerPage = 10
    static let dataFormat = "format=json&"
    static var clientID = "MjE1ODMxMzl8MTYxNTI2NTE3Mi4yMjE2MTE3"
    
    static let decoder = JSONDecoder()

    static func parse(query: String? = nil, pageCursor: Int = 1) -> Events? {
        var search = ""
        if let q = query {
            let spaceToPlus = q.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
            search = "q=\(spaceToPlus)&"
        }
        let urlString = apiBase + search + sorting + "per_page=\(resultsPerPage)&" + "page=\(pageCursor)&" + dataFormat + "client_id=\(clientID)"
        print(urlString)
        //print("query: \(query ?? ""), search: \(search)")
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                do {
                    let jsonEvents = try decoder.decode(Events.self, from: data)
                    return jsonEvents
                } catch {
                    print(error)
                }
            }
        }
        return nil
    }
    
    static func dateFrom(rfc: String?) -> Date? {
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let date = RFC3339DateFormatter.date(from: rfc ?? "") {
            return date
        } else { return nil }
    }
    
    static func stringDayFrom(date: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .none
        if let day = date {
            return dateFormatter.string(from: day)
        } else { return "______ _____ _ ____" }
    }
    
    static func stringTimeFrom(date: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        if let day = date {
            return dateFormatter.string(from: day)
        } else { return "____ __" }
        
    }
}
