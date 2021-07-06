//
//  Cache.swift
//  SeatGeekCodingExercise
//
//  Created by endOfLine on 7/1/21.
//

import UIKit

class Cache {
    
    var thumbnails = [Int: UIImage]()
    let placeholder = UIImage.placeholder
    
    func thumbnail(for event: EventsResponse.Event, completionHandler: @escaping (Bool, Error?) -> Void) {
        DispatchQueue.main.async {
            if self.thumbnails.keys.contains(event.id) {
                completionHandler(false, nil)
            } else {
                SGRequest().thumbnail(for: event) { data, error in
                    DispatchQueue.main.async {
                        if let data = data, let image = UIImage(data: data) {
                            self.thumbnails.merge([event.id : image]) { current, new in new }
                        } else {
                            self.thumbnails.merge([event.id : self.placeholder]) { current, new in new }
                        }
                        completionHandler(true, error)
                    }
                }
            }
        }
    }
}
