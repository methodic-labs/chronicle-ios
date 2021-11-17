//
//  Utils.swift
//  Utils
//
//  Created by Alfonce Nzioka on 11/3/21.
//

import Foundation

struct Utils {
    // converts a [String: String] dictionary to [FullQualified: String]
    static func toFqnUUIDMap(_ input: [String: String]) -> [FullQualifiedName: String] {
        var result: [FullQualifiedName: String] = [:]
        
        for (key, val) in input {
            if let fqn = FullQualifiedName.fromString(key) {
                result[fqn] = val
            }
        }
        
        return result
    }
}
