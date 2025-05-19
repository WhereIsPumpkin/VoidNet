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
    public var query: VoidNet.Query
    public var method: HTTPMethod
    public var headers: VoidNet.Headers
    public var body: VoidNet.Body

    // MARK: - Initialization
    public init(
        scheme: Scheme = .https,
        host: String,
        port: Int? = nil,
        path: String,
        query: VoidNet.Query = .emptyQuery,
        headers: VoidNet.Headers = .emptyHeaders,
        body: VoidNet.Body = .emptyBody,
        method: HTTPMethod
    ) {
        self.scheme = scheme
        self.host = host
        self.path = path
        self.port = port
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
        components.queryItems = {
            guard !query.isEmpty else { return nil }
            return query.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }()

        return components.url
    }
}

// MARK: - Extensions
public extension EndPoint {
    func asURLRequest() throws -> URLRequest {
        guard let url = url else {
            throw VoidNetError.invalidURL(components: debugDescription)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers

        if !body.isEmpty {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
                if request.value(forHTTPHeaderField: "Content-Type") == nil {
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
            } catch {
                throw VoidNetError.invalidBody
            }
        }

        return request
    }

    var debugDescription: String {
        var components = URLComponents()
        components.scheme = scheme.rawValue
        components.host = host
        components.port = port
        components.path = path
        components.queryItems = {
            guard !query.isEmpty else { return nil }
            return query.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }()

        let urlString = components.string ?? "Invalid URL components"
        let fullURLString = url?.absoluteString ?? urlString

        return """
        Debug Description:
        -------------------
        Full URL: \(fullURLString)
        Method: \(method.rawValue)
        Scheme: \(scheme.rawValue)
        Host: \(host)
        Port: \(port.map(String.init) ?? "N/A")
        Path: \(path)
        Query: \(query.isEmpty ? "None" : query.map { "\($0.key)=\($0.value)" }.joined(separator: "&"))
        Headers: \(headers.isEmpty ? "None" : headers.description)
        Body: \(body.isEmpty ? "None" : "\(body.count) key-value pairs")
        """
    }
}
