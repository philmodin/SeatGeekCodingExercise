//
//  Network.swift
//  SeatGeekCodingExercise
//
//  Created by endOfLine on 3/15/21.
//
//TODO: check if used with new Reachability else remove
import Foundation

struct Network {
    static var reachability: Reachability!
    enum Status: String {
        case unreachable, wifi, wwan
    }
    enum Error: Swift.Error {
        case failedToSetCallout
        case failedToSetDispatchQueue
        case failedToCreateWith(String)
        case failedToInitializeWith(sockaddr_in)
    }
}
