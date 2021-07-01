//
//  Int-Ext.swift
//  SeatGeekCodingExercise
//
//  Created by endOfLine on 7/1/21.
//

import Foundation

extension Int {

    func toDecimalString() -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? "error change to 0"
        
    }
}
