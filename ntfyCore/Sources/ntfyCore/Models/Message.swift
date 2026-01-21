//
//  Message.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 16.01.26.
//

import Foundation
public import UserNotifications

public struct Message: Codable, Identifiable {
    public var id: String
    public var time: Int64
    public var event: String
    public var topic: String
    public var message: String?
    public var title: String?
    public var priority: Int16?
    public var tags: [String]?
    public var actions: [Action]?
    public var click: String?
    public var pollId: String?
    
    public var userInfo: [AnyHashable: Any] {
        // This should mimic the way that the ntfy server encodes a message.
        // See server_firebase.go for more details.
        
        return [
            "id": id,
            "time": String(time),
            "event": event,
            "topic": topic,
            "message": message ?? "",
            "title": title ?? "",
            "priority": String(priority ?? 3),
            "tags": tags?.joined(separator: ",") ?? "",
            "actions": ActionCoder.encode(actions) ?? "",
            "click": click ?? "",
            "poll_id": pollId ?? ""
        ]
    }
    
    public init(
        id: String,
        time: Int64,
        event: String,
        topic: String,
        message: String?,
        title: String?,
        priority: Int16?,
        tags: [String]?,
        actions: [Action]?,
        click: String?,
        pollId: String?
    ) {
        self.id = id
        self.time = time
        self.event = event
        self.topic = topic
        self.message = message
        self.title = title
        self.priority = priority
        self.tags = tags
        self.actions = actions
        self.click = click
        self.pollId = pollId
    }
    
    public init?(from userInfo: [AnyHashable: Any]) {
        guard let id = userInfo["id"] as? String,
              let time = userInfo["time"] as? String,
              let event = userInfo["event"] as? String,
              let topic = userInfo["topic"] as? String,
              let timeInt = Int64(time),
              let message = userInfo["message"] as? String else {
            return nil
        }
        let title = userInfo["title"] as? String
        let priority = Int16(userInfo["priority"] as? String ?? "3") ?? 3
        let tags = (userInfo["tags"] as? String ?? "").components(separatedBy: ",")
        let actions = userInfo["actions"] as? String
        let click = userInfo["click"] as? String
        let pollId = userInfo["poll_id"] as? String
        
        self = Message(
            id: id,
            time: timeInt,
            event: event,
            topic: topic,
            message: message,
            title: title,
            priority: priority,
            tags: tags,
            actions: ActionCoder.parse(actions),
            click: click,
            pollId: pollId
        )
    }
}

public extension Message {
    func notificationContent(for serviceURL: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        
        let host = URL(string: serviceURL)?.host() ?? serviceURL
        
        if let message {
            content.body = message
        }
        content.title = title ?? "\(host)/\(topic)"
        
        if let actions, !actions.isEmpty {
            content.categoryIdentifier = "ntfyActions"
            let notificationActions = actions.map {
                UNNotificationAction(
                    identifier: $0.id,
                    title: $0.label,
                    options: [.foreground]
                )
            }
            
            let center = UNUserNotificationCenter.current()
            let category = UNNotificationCategory(identifier: "ntfyActions", actions: notificationActions, intentIdentifiers: [])
            center.setNotificationCategories([category])
        }
        
        if let emojis = self.tags?.compactMap({ EmojiCoder.shared.emoji(by: $0)?.unicode }).joined(separator: "") {
            if !content.title.isEmpty {
                content.title.insert(contentsOf: "\(emojis) ", at: content.title.startIndex)
            } else {
                content.body.insert(contentsOf: "\(emojis) ", at: content.body.startIndex)
            }
        }
        
        content.sound = .default
        content.threadIdentifier = "\(serviceURL)/\(topic)"
        let priority = self.priority.flatMap { Priority(rawValue: Int($0)) } ?? .default
        content.relevanceScore = priority.relevanceScore
        content.interruptionLevel = priority.interruptionLevel
        content.userInfo = userInfo
        content.userInfo["base_url"] = serviceURL
        
        return content
    }
}
