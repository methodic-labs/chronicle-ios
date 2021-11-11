//
//  Utils.swift
//  Utils
//
//  Created by Alfonce Nzioka on 11/10/21.
//

import Foundation

// generic Utilities class

struct Utils {
    static var formatter = ISO8601DateFormatter.init()
    
    static func convertDateToString(_ date: Date) -> String {
        return formatter.string(from: date)
    }
}
