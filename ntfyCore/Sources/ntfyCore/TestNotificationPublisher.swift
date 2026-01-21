//
//  TestNotificationPublisher.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 16.01.26.
//

public import Foundation

public protocol TestNotificationPublisher {
    func publish(
        to topic: TopicSubscription
    ) async throws
}

@Observable
public final class LiveTestNotificationPublisher: TestNotificationPublisher {
    let apiService: any APIService
    
    public init(apiService: any APIService) {
        self.apiService = apiService
    }
    
    public func publish(
        to topic: TopicSubscription
    ) async throws {
        let possibleTags: Array<String> = ["warning", "skull", "success", "triangular_flag_on_post", "de", "us", "dog", "cat", "rotating_light", "bike", "backup", "rsync", "this-s-a-tag", "ios"]
        let priority = Priority.allCases.randomElement()!
        let tags = Array(possibleTags.shuffled().prefix(Int.random(in: 0..<4)))
        let title = "Test: You can set a title if you like"
        let message = "This is a test notification from the ntfy iOS app. It has a priority of \(priority.rawValue). If you send another one, it may look different."
        
        try await apiService.publish(
            title: title,
            message: message,
            priority: priority,
            tags: tags,
            to: topic
        )
    }
}
