//
//  EndPoint.swift
//  VoidNet
//
//  Created by Saba Gogrichiani on 28.07.24.
//

import Foundation

public struct EndPoint {
    
    // MARK: - Properties
    public var scheme: Scheme
    public var host: String
    public var port: Int?
    public var path: String
    public var query: Query
    public var method: HTTPMethod
    public var headers: [String: String]
    public var body: Data?
    
    // MARK: - Initialization
    public init(
        scheme: Scheme = .https,
        host: String,
        port: Int? = nil,
        path: String,
        query: Query = .emptyQuery,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.query = query
        self.method = method
        self.headers = headers
        self.body = body
    }
    
    // MARK: - Computed Properties
    public var url: URL? {
        var components = URLComponents()
        components.scheme = scheme.rawValue
        components.host = host
        components.port = port
        components.path = path
        
        switch query {
        case .emptyQuery:
            components.queryItems = nil
        case .query(let queryItems):
            components.queryItems = queryItems.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        return components.url
    }
}

// MARK: - Extensions
extension EndPoint {
    
    public func asURLRequest() throws -> URLRequest {
        guard let url = self.url else {
            throw VoidNetError.invalidURL(components: debugDescription)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        return request
    }
    
    public var debugDescription: String {
        return
            """
            Scheme: \(scheme.rawValue)
            Host: \(host)
            Port: \(port ?? 0)
            Path: \(path)
            Query: \(query)
            Method: \(method.rawValue)
            Headers: \(headers)
            Body: \(body?.count ?? 0) bytes
            """
    }
}
