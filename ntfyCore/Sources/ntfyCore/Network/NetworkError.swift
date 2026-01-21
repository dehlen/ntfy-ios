//
//  NetworkError.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 16.01.26.
//

public import Foundation

public enum NetworkError: LocalizedError {
    case invalidURL
    case noHTTPResponse
    case unauthorized
    case invalidHTTPStatusCode(Int)
}
