//  SGRequest.swift
//  SeatGeekCodingExercise
//  Created by endOfLine on 6/26/21.

import UIKit

struct SGRequest {
    
    let host = "api.seatgeek.com"
    let apiBase = "https://api.seatgeek.com/2/events?"
    let resultsPerPage = 10
    let dataFormat = "format=json&"
    
    // clientID is secret and needs to be added by developer; check readme for instructions
    var clientID: String {
        get {
            // check if InfoSeatGeek.plist exists
            guard let filePath = Bundle.main.path(forResource: "InfoSeatGeek", ofType: "plist") else {
                fatalError("Could not locate InfoSeatGeek.plist")
            }
            let plistFile = NSDictionary(contentsOfFile: filePath)
            
            // check if ClientID key exists
            guard let value = plistFile?.object(forKey: "ClientID") as? String else {
                fatalError("Could not read ClientID in InfoSeatGeek.plist")
            }
            // check if ClientID value is template, empty, or contains space; if so, halt and print instructions
            if value.starts(with: "Paste client ID here") || value == "" || value.contains(" ") {
                print("⚠️ SeatGeek requires a valid API client ID")
                print("Register for a SeatGeek developer account and get an API client ID at:")
                print("https://seatgeek.com/account/develop")
                print("If you have an existing client ID, add it to InfoSeatGeek.plist\n")
                fatalError()
            }
            return value
        }
    }
    
    // using URLSession to fetch events with search query and page cursor, completing with optional results or error
    func event(searching query: String? = nil, at pageCursor: Int = 1, completionHandler: @escaping (EventsResponse?, Error?) -> Void) {
        
        // query string needs to be formatted by replacing " " with "+" for request URL
        var formattedQuery: String {
            if let query = query {
                let formattedQuery = query.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
                return "q=\(formattedQuery)&"
            } else { return "" }
        }
        
        // assembling request URL string
        let urlString = apiBase + formattedQuery + "per_page=\(resultsPerPage)&" + "page=\(pageCursor)&" + dataFormat + "client_id=\(clientID)"

        // make and check request URL
        guard let requestURL = URL(string: urlString) else {
            completionHandler(nil, nil)
            return
        }
        
        let request = URLRequest(url: requestURL)
        
        // perform the URL request
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            // check for data, otherwise send error
            if let data = data {
                // try decoding, otherwise send error
                do {
                    let eventsResponseDecoded = try JSONDecoder().decode(EventsResponse.self, from: data)
                    completionHandler(eventsResponseDecoded, nil)
                } catch {
                    completionHandler(nil, error)
                }
            } else if let error = error {
                completionHandler(nil, error)
            }            
        }.resume()
    }
    
    func thumbnail(for event: EventsResponse.Event, completionHandler: @escaping (Data?, Error?) -> Void) {
        
        // check for image URL
        guard let requestURL = event.performers[0]?.imageURL else {
            completionHandler(nil, nil)
            return
        }
        
        let request = URLRequest(url: requestURL)
        
        // perform the URL request
        URLSession.shared.dataTask(with: request) { data, response, error in
            // return the data even if it's nil
            completionHandler(data, error)
        }.resume()
    }
}
