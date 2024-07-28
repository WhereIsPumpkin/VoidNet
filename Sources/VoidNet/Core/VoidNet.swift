//
//  VoidNet.swift
//  VoidNet
//
//  Created by Saba Gogrichiani on 28.07.24.
//

import Foundation
import os

@available(iOS 15.0, *)
final class VoidNet {
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "VoidNet")
    
    public func request<T: Decodable>(
        endpoint: EndPoint,
        type: T.Type
    ) async throws -> T {
        do {
            
            let request = try endpoint.asURLRequest()
            logger.info("📤 Request: \(request.httpMethod ?? "Unknown method") \(request.url?.absoluteString ?? "Unknown URL", privacy: .public)")
            
            if let headers = request.allHTTPHeaderFields {
                logger.info("📤 Headers: \(headers)")
            }
            
            if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
                logger.info("📤 Body: \(bodyString)")
            }
            
            logger.info("⏳ Starting request...")
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("❌ Invalid response type")
                throw VoidNetError.invalidResponse
            }
            
            logger.info("📥 Received response with status code: \(httpResponse.statusCode)")
            logger.info("📥 Response headers: \(httpResponse.allHeaderFields)")
            
            if let responseString = String(data: data, encoding: .utf8) {
                logger.info("📥 Response body: \(responseString)")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                logger.error("❌ HTTP error: \(httpResponse.statusCode)")
                throw VoidNetError.httpError(httpResponse.statusCode)
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                logger.info("✅ Successfully decoded response of type: \(String(describing: T.self))")
                return decodedResponse
            } catch {
                logger.error("❌ Decoding error: \(error.localizedDescription)")
                throw VoidNetError.decodingError(error)
            }
        } catch {
            logger.error("❌ Request failed: \(error.localizedDescription)")
            throw error
        }
    }
}
