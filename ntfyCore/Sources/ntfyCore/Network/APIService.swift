//
//  APIService.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 16.01.26.
//

public import Foundation
import OSLog

public protocol APIService {
    func poll(topic: TopicSubscription, since messageID: String?) async throws -> [Message]
    func poll(topic: TopicSubscription, messageID: String) async throws -> Message
    func publish(
        title: String,
        message: String,
        priority: Priority,
        tags: [String],
        to topic: TopicSubscription
    ) async throws
}

public final class LiveAPIService: APIService {
    let network: Network
    let userStore: any UserStore
    
    public convenience init(userStore: any UserStore) {
        let userAgent = "ntfy/\(Bundle.main.version) (build \(Bundle.main.build); iOS \(Bundle.main.osVersion))"
    
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        configuration.httpAdditionalHeaders = [
            "User-Agent": userAgent
        ]
        
        let session = URLSession(configuration: configuration)
        
        self.init(
            session: session,
            userStore: userStore
        )
    }
    
    public init(session: URLSession, userStore: any UserStore) {
        self.network = Network(session: session)
        self.userStore = userStore
    }
    
    public func poll(topic: TopicSubscription, since messageID: String?) async throws -> [Message] {
        guard let baseURL = URL(string: topic.serviceURL) else {
            throw NetworkError.invalidURL
        }
        
        let request = URLRequestBuilder(baseURL: baseURL)
            .get("/\(topic.topic)/json")
            .queryItems([
                "poll": "1",
                "since": messageID ?? "all"
            ])
            .basicAuth(credentials: credentials(for: topic))

        return try await network.send(request)
    }
    
    public func poll(topic: TopicSubscription, messageID: String) async throws -> Message {
        guard let baseURL = URL(string: topic.serviceURL) else {
            throw NetworkError.invalidURL
        }
        
        let request = URLRequestBuilder(baseURL: baseURL)
            .get("/\(topic.topic)/json")
            .queryItems([
                "poll": "1",
                "id": messageID
            ])
            .basicAuth(credentials: credentials(for: topic))

        return try await network.send(request)
    }
    
    public func publish(
        title: String,
        message: String,
        priority: Priority = .default,
        tags: [String] = [],
        to topic: TopicSubscription
    ) async throws {
        guard let baseURL = URL(string: topic.serviceURL) else {
            throw NetworkError.invalidURL
        }
        
        let request = URLRequestBuilder(baseURL: baseURL)
            .post("/\(topic.topic)")
            .setValue(title, forHeader: "Title")
            .setValue(String(priority.rawValue), forHeader: "Priority")
            .setValue(tags.joined(separator: ","), forHeader: "Tags")
            .body(data: Data(message.utf8))
            .basicAuth(credentials: credentials(for: topic))
        
        try await network.send(request)
    }
    
    private func credentials(for topic: TopicSubscription) -> Credentials? {
        guard let user = userStore.users.first(where: { $0.serviceURL == topic.serviceURL }) else {
            return nil
        }
        
        guard let password = try? userStore.fetchPassword(for: user.id) else {
            return nil
        }
        return Credentials(username: user.username, password: password)
    }
}
