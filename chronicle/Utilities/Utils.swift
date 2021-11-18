//
//  Utils.swift
//  Utils
//
//  Created by Alfonce Nzioka on 11/3/21.
//

import Foundation

struct Utils {
    // converts a [String: String] dictionary to [FullQualified: String]
    static func toFqnUUIDMap(_ input: [String: String]) -> [FullQualifiedName: UUID] {
        var result: [FullQualifiedName: UUID] = [:]
        
        for (key, val) in input {
            if let fqn = FullQualifiedName.fromString(key), let uuid = UUID.init(uuidString: val) {
                result[fqn] = uuid
            }
        }
        
        return result
    }
}
