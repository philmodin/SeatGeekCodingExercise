//
//  Cache.swift
//  SeatGeekCodingExercise
//
//  Created by endOfLine on 7/1/21.
//

import UIKit

class Cache {
    
    var thumbnails = [Int: Data?]()
    
    func loadThumbnails(for newEvents: [EventsResponse.Event], completionHandler: @escaping (Bool) -> Void) {
        var eventsProcessed = 0
        
        for event in newEvents {
            
            if thumbnails.keys.contains(event.id) {
                eventsProcessed += 1
                if eventsProcessed == newEvents.count { completionHandler(true) }
                
            } else {
                SGRequest().thumbnail(for: event) { data, _ in
                    
                    if let data = data {
                        self.thumbnails.merge([event.id : data]) { _, new in new }
                        
                    } else {
                        self.thumbnails.merge([event.id : nil]) { _, new in new }
                    }
                    
                    eventsProcessed += 1
                    if eventsProcessed == newEvents.count { completionHandler(true) }
                }
            }
        }
    }
}
