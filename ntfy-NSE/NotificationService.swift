//
//  NotificationService.swift
//  ntfy-NSE
//
//  Created by von Knobelsdorff, David on 20.01.26.
//

import ntfyCore
import OSLog
import UserNotifications
import SwiftData

@MainActor class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    let notificationHandler: NotificationHandler = LiveNotificationHandler()

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            let userInfo = bestAttemptContent.userInfo
            
            guard let message = Message(from: userInfo) else {
                NtfyLogger.messaging.error("Message canot be parsed from userInfo: \(userInfo, privacy: .public)")
                contentHandler(bestAttemptContent)
                return
            }
            
            guard let event = MessageEvent(rawValue: message.event) else {
                NtfyLogger.messaging.error("Received unknown message event: \(message.event, privacy: .public)")
                contentHandler(bestAttemptContent)
                return
            }

            switch event {
            case .pollRequest:
                Task {
                    await notificationHandler.handlePollRequest(request, bestAttemptContent, message, contentHandler)
                }
            case .message:
                notificationHandler.handleMessage(request, bestAttemptContent, message, contentHandler)
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
