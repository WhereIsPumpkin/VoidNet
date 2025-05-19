//
//  RequestComponents.swift
//  VoidNet
//
//  Created by Saba Gogrichiani on 19.05.25.
//

import Foundation

public extension VoidNet {
    
    typealias Headers = [String: String]
    
    typealias Query = [String: Any]
    
    typealias Body = [String: Any]
    
    typealias JSON = [String: Any]
    
    typealias JSONArray = [[String: Any]]
    
}

public extension VoidNet.Headers {
    
    static var emptyHeaders: VoidNet.Headers { return [:] }
    
}

public extension VoidNet.Query {
    
    static var emptyQuery: VoidNet.Query { return [:] }
    
}

public extension VoidNet.Body {
    
    static var emptyBody: VoidNet.Body { return [:] }
    
}
