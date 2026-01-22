//
//  NotificationHandler.swift
//  ntfy-NSE
//
//  Created by von Knobelsdorff, David on 21.01.26.
//

import Foundation
import ntfyCore
import OSLog
import SwiftData
import UserNotifications

@MainActor protocol NotificationHandler {
    func handleMessage(_ request: UNNotificationRequest, _ content: UNMutableNotificationContent, _ message: Message, _ contentHandler: @escaping (UNNotificationContent) -> Void)
    func handlePollRequest(_ request: UNNotificationRequest, _ content: UNMutableNotificationContent, _ pollRequest: Message, _ contentHandler: @escaping (UNNotificationContent) -> Void) async
}

@MainActor final class LiveNotificationHandler: NotificationHandler {
    private var dependencies: DependencyContainer {
        DependencyContainer.live
    }
    
    func handleMessage(_ request: UNNotificationRequest, _ content: UNMutableNotificationContent, _ message: Message, _ contentHandler: @escaping (UNNotificationContent) -> Void) {
        NtfyLogger.nse.debug("Handling message")

        let baseURL = content.userInfo["base_url"] as? String ?? Bundle.main.appBaseUrl
        let modifiedContent = message.notificationContent(for: baseURL)
        
        guard let topic = try? dependencies.store.topic(serviceURL: baseURL, name: message.topic) else {
            NtfyLogger.nse.debug("Topic \(message.topic, privacy: .public) (\(baseURL, privacy: .public)) not found in local store")
            contentHandler(modifiedContent)
            return
        }

        let notification = Notification(
            title: message.title,
            message: message.message ?? "",
            timestamp: TimeInterval(message.time),
            priority: message.priority.flatMap { Priority(rawValue: Int($0)) } ?? .default,
            click: message.click.flatMap { URL(string: $0) },
            tags: message.tags?.joined(separator: ","),
            actions: ActionCoder.encode(message.actions),
            messageID: message.id,
            topic: topic
        )
        
        dependencies.store.save(notification, to: topic)
        contentHandler(modifiedContent)
    }
    
    func handlePollRequest(_ request: UNNotificationRequest, _ content: UNMutableNotificationContent, _ pollRequest: Message, _ contentHandler: @escaping (UNNotificationContent) -> Void) async {
        NtfyLogger.nse.debug("Handling poll request")

        let baseURL = content.userInfo["base_url"] as? String ?? Bundle.main.appBaseUrl

        guard let pollId = pollRequest.pollId else {
            NtfyLogger.nse.debug("No pollId found in poll request")
            contentHandler(content)
            return
        }

        guard let topic = try? dependencies.store.topic(serviceURL: baseURL, name: pollRequest.topic) else {
            NtfyLogger.nse.debug("Topic \(pollRequest.topic, privacy: .public) of poll request not found in local store")
            contentHandler(content)
            return
        }

        guard let message = try? await dependencies.apiService.poll(topic: topic, messageID: pollId) else {
            NtfyLogger.nse.debug("Failed to fetch message with id \(pollId, privacy: .public) of topic \(topic.topic, privacy: .public) (\(topic.serviceURL, privacy: .public))")
            contentHandler(content)
            return
        }
        
        handleMessage(request, content, message, contentHandler)
    }
}
