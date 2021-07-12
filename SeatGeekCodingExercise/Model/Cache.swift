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
    
    func thumbnail(for event: EventsResponse.Event, completionHandler: @escaping (Result<Bool, Error>) -> Void) {
        DispatchQueue.main.async {
            if self.thumbnails.keys.contains(event.id) {
                completionHandler(.success(false))
            } else {
                SGRequest().thumbnail(for: event) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case.failure(let error): completionHandler(.failure(error))
                        case.success(let data):
                            if let image = UIImage(data: data) {
                                self.thumbnails.merge([event.id : image]) { current, new in new }
                            } else {
                                self.thumbnails.merge([event.id : self.placeholder]) { current, new in new }
                            }
                            completionHandler(.success(true))
                        }
                    }
                }
            }
        }
    }
}
