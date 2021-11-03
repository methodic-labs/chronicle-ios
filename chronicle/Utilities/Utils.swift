//
//  Utils.swift
//  Utils
//
//  Created by Alfonce Nzioka on 11/3/21.
//

import Foundation

struct Utils {
    // converts a [String: String] dictionary to [FullQualified: UUID]
    static func toFqnUUIDMap(_ input: [String: String]) -> [FullQualifiedName: UUID] {
        var result: [FullQualifiedName: UUID] = [:]
        
        for (key, val) in input {
            if let fqn = FullQualifiedName.fromString(key), let id = UUID(uuidString: val) {
                result[fqn] = id
            }
        }
        
        return result
    }
}
