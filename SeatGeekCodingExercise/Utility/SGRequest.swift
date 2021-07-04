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
    
    func totalEvents(for query: String, completionHandler: @escaping (Int?, Error?) -> Void) {
        guard let request = buildRequest(query: query, batchSize: 1, page: 1)
        else {
            completionHandler(nil, nil)
            return
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    let eventsResponseDecoded = try JSONDecoder().decode(EventsResponse.self, from: data)
                    completionHandler(eventsResponseDecoded.meta.total, nil)
                } catch {
                    completionHandler(nil, error)
                }
            } else if let error = error {
                completionHandler(nil, error)
            }
        }.resume()
    }
    
    func event(for query: String, at indexPath: IndexPath, completionHandler: @escaping (EventsResponse.Event?, Error?) -> Void) {
        guard let request = buildRequest(query: query, batchSize: 1, page: indexPath.row + 1)
        else {
            completionHandler(nil, nil)
            return
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    let eventsResponse = try JSONDecoder().decode(EventsResponse.self, from: data)
                    completionHandler(eventsResponse.events.first, nil)
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

extension SGRequest {
    
    private func buildRequest(query: String, batchSize: Int, page: Int) -> URLRequest? {
        let formattedQuery = formatQuery(query)
        let urlString = assembleURLString(formattedQuery: formattedQuery, batchSize: batchSize, pageCursor: page)
        guard let url = URL(string: urlString) else { return nil }
        return URLRequest(url: url)
    }
    
    private func formatQuery(_ query: String) -> String {
        // query string needs to be formatted by replacing " " with "+" for request URL
        let formattedQuery = query.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        return formattedQuery
    }
    
    private func assembleURLString(formattedQuery: String, batchSize: Int, pageCursor: Int) -> String {
        return apiBase
            + "q=\(formattedQuery)&"
            + "per_page=\(batchSize)&"
            + "page=\(pageCursor)&"
            + dataFormat
            + "client_id=\(clientID)"
    }
    
}
