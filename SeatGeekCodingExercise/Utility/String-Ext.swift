//
//  String-Ext.swift
//  SeatGeekCodingExercise
//
//  Created by endOfLine on 7/5/21.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
