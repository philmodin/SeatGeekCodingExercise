//  SGRequest.swift
//  SeatGeekCodingExercise
//  Created by endOfLine on 6/26/21.

import UIKit

struct SGRequest {
    
    let host = "api.seatgeek.com"
    let apiBase = "https://api.seatgeek.com/2/events?"
    let resultsPerPage = 10
    let dataFormat = "format=json&"
    
    //  clientID is secret and needs to be added to InfoSeatGeek.plist by each developer; check readme for instructions
    var clientID = ""
    
    let errorURL = "Invalid URL"
    let errorUnknown = "Unknown error"
    
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
    
    func eventsTotalCount(for query: String, completion: @escaping (Result<Int, Error>) -> Void) {
        guard let url = buildURL(query: query, page: 1)
        else {
            completion(.failure(errorURL))
            return
        }
        getEventsResponse(for: url) { result in
            switch result {
            case .success(let eventsResponse):
                completion(.success(eventsResponse.meta.total))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func event(for query: String, at indexPath: IndexPath, completion: @escaping (Result<EventsResponse.Event, Error>) -> Void) {
        guard let url = buildURL(query: query, page: indexPath.row + 1)
        else {
            completion(.failure(errorURL))
            return
        }
        getEventsResponse(for: url) { result in
            switch result {
            case .success(let eventsResponse) :
                completion(.success(eventsResponse.events.first!))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func thumbnail(for event: EventsResponse.Event, completion: @escaping (Result<Data, Error>) -> Void) {
        
        guard let url = event.performers[0]?.imageURL else {
            completion(.failure(errorURL))
            return
        }
                
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let data = data {
                    completion(.success(data))
                } else {
                    completion(.failure(error ?? errorUnknown))
                }
            }
        }.resume()
    }
    
}

extension SGRequest {
    
    private func getEventsResponse(for url: URL, completion: @escaping (Result<EventsResponse, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    if let statusResponseDecoded = try? JSONDecoder().decode(StatusResponse.self, from: data) {
                        throw statusResponseDecoded.message
                    }
                    let eventsResponse = try JSONDecoder().decode(EventsResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(eventsResponse))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(error ?? errorUnknown))
                }
            }
        }.resume()
    }
    
}

extension SGRequest {
    
    private func buildURL(query: String, page: Int) -> URL? {
        let formattedQuery = formatQuery(query)
        let urlString = assembleURLString(formattedQuery: formattedQuery, pageCursor: page)
        return  URL(string: urlString)
    }
    
    private func formatQuery(_ query: String) -> String {
        // query string needs to be formatted by replacing " " with "+" for request URL
        let formattedQuery = query.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        return formattedQuery
    }
    
    private func assembleURLString(formattedQuery: String, batchSize: Int = 1, pageCursor: Int) -> String {
        return apiBase
            + "q=\(formattedQuery)&"
            + "per_page=\(batchSize)&"
            + "page=\(pageCursor)&"
            + dataFormat
            + "client_id=\(clientID)"
    }
    
}
