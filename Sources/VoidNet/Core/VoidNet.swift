//
//  VoidNet.swift
//  VoidNet
//
//  Created by Saba Gogrichiani on 28.07.24.
//

import Foundation
import os

public final class VoidNet {
    public static let shared = VoidNet()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "VoidNet")

    private init() {}

    public func request<T: Decodable>(
        endpoint: EndPoint,
        type _: T.Type = EmptyData.self
    ) async throws -> T {
        do {
            let request = try endpoint.asURLRequest()
            logRequest(request)

            logger.info("⏳ Starting request...")
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("❌ Invalid response type")
                throw VoidNetError.invalidResponse
            }

            logResponse(httpResponse, data: data, error: nil)

            guard (200 ... 299).contains(httpResponse.statusCode) else {
                logger.error("❌ HTTP error: \(httpResponse.statusCode)")
                throw VoidNetError.httpError(httpResponse.statusCode)
            }

            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                return decodedResponse
            } catch {
                logger.error("❌ Decoding error: \(error.localizedDescription)")
                throw VoidNetError.decodingError(error)
            }
        } catch let VoidNetError.invalidURL(components) {
            logger.error("Invalid URL: \n\(components)")
            throw VoidNetError.invalidURL(components: components)
        } catch {
            logger.error("Unexpected error: \(error.localizedDescription)")
            throw error
        }
    }
}

extension VoidNet {
    private func logRequest(_ request: URLRequest) {
        logger.info("📤 Request: \(request.httpMethod ?? "Unknown method") \(request.url?.absoluteString ?? "Unknown URL", privacy: .public)")

        if let headers = request.allHTTPHeaderFields {
            logger.info("📤 Headers: \(formatHeaders(headers))")
        }

        if let body = request.httpBody,
           let jsonObject = try? JSONSerialization.jsonObject(with: body),
           let prettyPrintedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let bodyString = String(data: prettyPrintedData, encoding: .utf8)
        {
            logger.info("📤 Body: \(bodyString, privacy: .sensitive)")
        }
    }

    private func logResponse(_ response: HTTPURLResponse, data: Data?, error: Error?) {
        logger.info("📥 Received response with status code: \(response.statusCode)")
        logger.info("📥 Response headers: \(formatHeaders(response.allHeaderFields))")

        if let data = data,
           let jsonObject = try? JSONSerialization.jsonObject(with: data),
           let prettyPrintedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let responseString = String(data: prettyPrintedData, encoding: .utf8)
        {
            logger.info("📥 Response body: \(responseString, privacy: .sensitive)")
        }

        if let error = error {
            logger.error("❌ Error: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func formatHeaders(_ headers: [AnyHashable: Any]) -> String {
        var formattedHeaders = ""
        for (key, value) in headers {
            formattedHeaders += "\(key): \(value)\n"
        }
        return formattedHeaders.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
