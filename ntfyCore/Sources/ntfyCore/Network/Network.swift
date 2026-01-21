//
//  Network.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 16.01.26.
//

public import Foundation
import OSLog

public final class Network {
    let session: URLSession

    public convenience init() {
        let userAgent = "ntfy/\(Bundle.main.version) (build \(Bundle.main.build); iOS \(Bundle.main.osVersion))"
    
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        configuration.httpAdditionalHeaders = [
            "User-Agent": userAgent
        ]
        
        self.init(
            session: URLSession(configuration: configuration)
        )
    }
    
    public init(session: URLSession) {
        self.session = session
    }
    
    public func send(
        _ request: URLRequest
    ) async throws -> Void {
        return try await send(request) { _ in
            ()
        }
    }
    
    public func send<T: Decodable>(
        _ request: URLRequest,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        return try await send(request) { data in
            return try decoder.decode(T.self, from: data)
        }
    }
    
    private func send<T>(
        _ request: URLRequest,
        parse: (Data) throws -> T
    ) async throws -> T {
        let traceID = UUID()
        defer {
            NtfyLogger.network.debug("[HTTP] Request finished. ID: \(traceID, privacy: .public)")
        }
        
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse else {
            NtfyLogger.network.debug("[HTTP] Request had no http response. ID: \(traceID, privacy: .public)")
            throw NetworkError.noHTTPResponse
        }
        
        switch response.statusCode {
        case 200 ... 299:
            do {
                return try parse(data)
            } catch {
                NtfyLogger.network.debug("[HTTP] Failed to parse response: \(error.localizedDescription). ID: \(traceID, privacy: .public)")
                throw error
            }
            
        case 401:
            NtfyLogger.network.debug("[HTTP] Failed with unauthorized status code. ID: \(traceID, privacy: .public)")
            throw NetworkError.unauthorized
            
        default:
            NtfyLogger.network.debug("[HTTP] Failed with HTTP status code: \(response.statusCode, privacy: .public). ID: \(traceID, privacy: .public)")
            throw NetworkError.invalidHTTPStatusCode(response.statusCode)
        }
    }
}
