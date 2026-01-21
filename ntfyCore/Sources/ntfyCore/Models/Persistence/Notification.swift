//
//  Notification.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 14.01.26.
//

public import Foundation
public import SwiftData

@Model
public class Notification: Identifiable {
    @Attribute(.unique) public var id: String = UUID().uuidString
    public var title: String?
    public var message: String
    public var timestamp: TimeInterval
    public var priority: Priority
    public var click: URL?
    public var tags: String?
    public var actions: String?
    public var messageID: String
    public var topic: TopicSubscription
    
    public init(
        id: String = UUID().uuidString,
        title: String? = nil,
        message: String,
        timestamp: TimeInterval = Date.now.timeIntervalSince1970,
        priority: Priority = .default,
        click: URL? = nil,
        tags: String? = nil,
        actions: String? = nil,
        messageID: String,
        topic: TopicSubscription
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.priority = priority
        self.click = click
        self.tags = tags
        self.actions = actions
        self.messageID = messageID
        self.topic = topic
    }
    
    @Transient
    public var date: Date {
        Date(timeIntervalSince1970: timestamp)
    }
    
    @Transient
    public var tagSet: Set<String> {
        Set(tags?
            .split(separator: ",")
            .map(String.init) ?? [])
    }
    
    @Transient
    @MainActor
    public var availableActions: [Action] {
        ActionCoder.parse(actions) ?? []
    }
    
    @Transient
    @MainActor
    public var viewActions: [Action] {
        availableActions.filter {
            $0.action == "view" && $0.url != nil
        }
    }
}
