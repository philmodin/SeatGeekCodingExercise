//
//  Cache.swift
//  SeatGeekCodingExercise
//
//  Created by endOfLine on 7/1/21.
//

import UIKit

class Cache {
    
    var thumbnails = [Int: UIImage?]()
    
    func loadThumbnails(for newEvents: [EventsResponse.Event], addedNewThumbnails: @escaping (Bool) -> Void) {
        
        var hasNewThumbnails = false
        var eventsProcessed = 0
        
        for event in newEvents {
            
            if thumbnails.keys.contains(event.id) {
                eventsProcessed += 1
                if eventsProcessed == newEvents.count { addedNewThumbnails(hasNewThumbnails) }
                
            } else {
                SGRequest().thumbnail(for: event) { data, _ in
                    
                    if let data = data, let image = UIImage(data: data) {
                        self.thumbnails.merge([event.id : image]) { _, new in new }
                        hasNewThumbnails = true
                    }
                    
                    eventsProcessed += 1
                    if eventsProcessed == newEvents.count { addedNewThumbnails(hasNewThumbnails) }
                }
            }
        }
    }
}
