//  SGRequest.swift
//  SeatGeekCodingExercise
//  Created by endOfLine on 6/26/21.

import UIKit

struct SGRequest {
    
    let host = "api.seatgeek.com"
    let apiBase = "https://api.seatgeek.com/2/events?"
    let resultsPerPage = 10
    let dataFormat = "format=json&"
    var clientID = ""
    //  clientID is secret and needs to be added to InfoSeatGeek.plist by developer; check readme for instructions
    let errorURLRequest = "Invalid URLRequest"
    let errorURL = "Invalid URL"
    
    init(testing clientID: String? = nil) {
        if let clientID = clientID {
            self.clientID = clientID
        } else {
            self.clientID = getClientID()
        }
    }
    
    private func getClientID() -> String {
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

extension SGRequest {
    
    func eventsTotalCount(for query: String, completion: @escaping (Int?, Error?) -> Void) {
        guard let request = buildRequest(query: query, batchSize: 1, page: 1)
        else {
            completion(nil, errorURLRequest)
            return
        }
        getEventsResponse(for: request) { eventsResponse, error in
            completion(eventsResponse?.meta.total, error)
        }
    }
    
    func event(for query: String, at indexPath: IndexPath, completion: @escaping (EventsResponse.Event?, Error?) -> Void) {
        guard let request = buildRequest(query: query, batchSize: 1, page: indexPath.row + 1)
        else {
            completion(nil, errorURLRequest)
            return
        }
        getEventsResponse(for: request) { eventsResponse, error in
            completion(eventsResponse?.events.first, error)
        }
    }
    
    func thumbnail(for event: EventsResponse.Event, completion: @escaping (Data?, Error?) -> Void) {
        
        guard let requestURL = event.performers[0]?.imageURL else {
            completion(nil, errorURL)
            return
        }
        
        let request = URLRequest(url: requestURL)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            completion(data, error)
        }.resume()
    }
    
}

extension SGRequest {
    
    private func getEventsResponse(for request: URLRequest, completion: @escaping (EventsResponse?, Error?) -> Void) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data {
                do {
                    if let statusResponseDecoded = try? JSONDecoder().decode(StatusResponse.self, from: data) {
                        throw statusResponseDecoded.message
                    }
                    let eventsResponse = try JSONDecoder().decode(EventsResponse.self, from: data)
                    completion(eventsResponse, nil)
                } catch {
                    completion(nil, error)
                }
            } else {
                completion(nil, error)
            }
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
