//
//  FullQualifiedName.swift
//  FullQualifiedName
//
//  Created by Alfonce Nzioka on 11/3/21.
//

import Foundation

struct FullQualifiedName: Codable, Hashable {
    let namespace: String
    let name: String
    
    init(namespace: String, name: String) {
        self.namespace = namespace
        self.name = name
    }
}

extension FullQualifiedName {
    static var dateLoggedFqn = FullQualifiedName(namespace: "ol", name: "datelogged")
    static var idFqn = FullQualifiedName(namespace: "ol", name: "id")
    static var valuesFqn = FullQualifiedName(namespace: "ol", name: "values")
    static var variableFqn = FullQualifiedName(namespace: "ol", name: "variable")
    
    // add other FQNS here that might be needed
    static var fqns: Set<FullQualifiedName> {
        [
            idFqn,
            variableFqn,
            valuesFqn,
            dateLoggedFqn
        ]
    }
    
    static func fromString(_ input: String) -> FullQualifiedName? {
        let tokens = input.split(separator: ".")
        guard tokens.count == 2 else {
            return nil
        }
        
        return FullQualifiedName(namespace: String(tokens[0]), name: String(tokens[1]))
    }
}
