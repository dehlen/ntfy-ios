//
//  NotificationService.swift
//  ntfy-NSE
//
//  Created by von Knobelsdorff, David on 20.01.26.
//

import ntfyCore
import OSLog
import UserNotifications
internal import SwiftData

@MainActor class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            let userInfo = bestAttemptContent.userInfo
            
            guard let message = Message(from: userInfo) else {
                NtfyLogger.messaging.error("Message canot be parsed from userInfo: \(userInfo, privacy: .public)")
                contentHandler(request.content)
                return
            }
            
            switch message.event {
            case "poll_request":
                Task {
                    await handlePollRequest(request, bestAttemptContent, message, contentHandler)
                }
            case "message":
                handleMessage(request, bestAttemptContent, message, contentHandler)
            default:
                NtfyLogger.messaging.warning("Unknown message event received: \(message.event, privacy: .public)")
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    private func handleMessage(_ request: UNNotificationRequest, _ content: UNMutableNotificationContent, _ message: Message, _ contentHandler: @escaping (UNNotificationContent) -> Void) {
        let baseURL = content.userInfo["base_url"] as? String ?? Bundle.main.appBaseUrl
        let modifiedContent = message.notificationContent(for: baseURL)
        
        guard let topic = try? CompositionRoot.store.topics().first(where: {
            $0.serviceURL == baseURL && $0.topic == message.topic
        }) else {
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
        
        CompositionRoot.store.context.insert(notification)
        contentHandler(modifiedContent)
    }
    
    private func handlePollRequest(_ request: UNNotificationRequest, _ content: UNMutableNotificationContent, _ pollRequest: Message, _ contentHandler: @escaping (UNNotificationContent) -> Void) async {
        guard let pollId = pollRequest.pollId else {
            contentHandler(content)
            return
        }
        
        let baseURL = content.userInfo["base_url"] as? String ?? Bundle.main.appBaseUrl

        guard let topic = try? CompositionRoot.store.topics().first(where: {
            $0.serviceURL == baseURL && $0.topic == pollRequest.topic
        }) else {
            contentHandler(content)
            return
        }
        
        guard let message = try? await CompositionRoot.apiService.poll(topic: topic, messageID: pollId) else {
            contentHandler(content)
            return
        }
        
        handleMessage(request, content, message, contentHandler)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
