//
//  Double-Ext.swift
//  SeatGeekCodingExercise
//
//  Created by endOfLine on 7/1/21.
//

import Foundation

extension Double {
    init(decimal: Double) {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let eventsCount = (numberFormatter.string(from: NSNumber(value: eventsTotal)) ?? "0")
    }
}
