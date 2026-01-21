//
//  Store.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 16.01.26.
//

import Foundation
public import SwiftData
 
public protocol Store {
    var container: ModelContainer { get }
    var context: ModelContext { get }
    
    func topics() throws -> [TopicSubscription]
    func topic(serviceURL: String, name: String) throws -> TopicSubscription?
    func pollNotifications(for topic: TopicSubscription) async throws -> [Message]
}

public final class LiveStore: Store {
    public let container: ModelContainer
    public let context: ModelContext
    
    private let apiService: any APIService
    
    public init(
        apiService: any APIService
    ) {
        do {
            let schema = Schema([TopicSubscription.self, Notification.self])
            let config = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true,
                groupContainer: .identifier("group.\(Bundle.main.bundleIdentifier!)")
            )
            container = try ModelContainer(
                for: schema,
                configurations: config
            )
            
            context = container.mainContext
            context.autosaveEnabled = true
            
            self.apiService = apiService
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    public func topics() throws -> [TopicSubscription] {
        let fetchDesciptor = FetchDescriptor<TopicSubscription>()
        return try context.fetch(fetchDesciptor)
    }
    
    public func topic(serviceURL: String, name: String) throws -> TopicSubscription? {
        let fetchDesciptor = FetchDescriptor<TopicSubscription>(predicate: #Predicate {
            $0.topic == name && $0.serviceURL == serviceURL
        })
        return try context.fetch(fetchDesciptor).first
    }
    
    public func pollNotifications(for topic: TopicSubscription) async throws -> [Message] {
        let messages = try await apiService.poll(topic: topic, since: topic.lastNotificationId)
        let notifications = messages.map {
            Notification(
                title: $0.title,
                message: $0.message ?? "",
                timestamp: TimeInterval($0.time),
                priority: $0.priority.flatMap { Priority(rawValue: Int($0)) } ?? .default,
                click: $0.click.flatMap(URL.init(string:)),
                tags: $0.tags?.joined(separator: ","),
                actions: ActionCoder.encode($0.actions),
                messageID: $0.id,
                topic: topic
            )
        }
        for notification in notifications {
            context.insert(notification)
        }
        return messages
    }
}
