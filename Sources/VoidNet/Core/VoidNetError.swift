//
//  VoidNetError.swift
//  VoidNet
//
//  Created by Saba Gogrichiani on 28.07.24.
//

public enum VoidNetError: Error {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
}
