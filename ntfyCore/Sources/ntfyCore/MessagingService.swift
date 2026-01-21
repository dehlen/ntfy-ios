//
//  MessagingService.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 16.01.26.
//

import FirebaseCore
public import FirebaseMessaging
import Foundation
import OSLog
public import UIKit

public protocol MessagingService {
    func configure()
    func enableRemoteNotifications(for application: UIApplication) async
    func updateDeviceToken(_ deviceToken: Data)
    func handleRemoteNotification(userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult
}

public final class LiveMessagingService: NSObject, MessagingService {
    private let pollTopic = "~poll" // See ntfy server if ever changed
    
    private let store: any Store
    private let appRouter: any Router
    private let application: UIApplication = .shared
    private let userNotificationCenter = UNUserNotificationCenter.current()
    
    public init(store: any Store, appRouter: any Router) {
        self.store = store
        self.appRouter = appRouter
        super.init()
    }
    
    public func configure() {
        FirebaseApp.configure()
    }
    
    public func enableRemoteNotifications(for application: UIApplication) async {
        userNotificationCenter.delegate = self
        Messaging.messaging().delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        do {
            try await userNotificationCenter.requestAuthorization(options: options)
            application.registerForRemoteNotifications()
        } catch {
            NtfyLogger.messaging.error("Could not request authorization for remote notifications: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    public func updateDeviceToken(_ deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    public func handleRemoteNotification(userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        NtfyLogger.messaging.debug("Background notification received: \(userInfo, privacy: .public)")
        
        // Exit out early if this message is not expected
        guard
            let topic = userInfo["topic"] as? String,
            topic == pollTopic
        else {
            return .noData
        }

        var newData: Bool = false

        do {
            let topics = try store.topics()
            for topic in topics {
                let messages = try await store.pollNotifications(for: topic)
                if !messages.isEmpty {
                    newData = true
                }
                for message in messages {
                    try await scheduleLocalNotification(message, topic: topic)
                }
            }
        } catch {
            NtfyLogger.messaging.error("Failed to handle remote notification: \(error.localizedDescription, privacy: .public)")
            return .noData
        }

        return newData ? .newData : .noData
    }
    
    private func scheduleLocalNotification(_ message: Message, topic: TopicSubscription) async throws {
        let content = message.notificationContent(for: topic.serviceURL)
        let request = UNNotificationRequest(identifier: message.id, content: content, trigger: nil)
        try await userNotificationCenter.add(request)
    }
}

extension LiveMessagingService: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        NtfyLogger.messaging.debug("Notification received via userNotificationCenter(willPresent): \(userInfo, privacy: .public)")
        return [.banner, .sound]
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo
        NtfyLogger.messaging.debug("Notification received via userNotificationCenter(didReceive): \(userInfo, privacy: .public)")
        guard let message = Message(from: userInfo) else {
            NtfyLogger.messaging.warning("Cannot convert userInfo to message: \(userInfo, privacy: .public)")
            return
        }
        
        if let click = message.click, let url = URL(string: click) {
            await application.open(url)
            return
        }
        
        let topics = try? store.topics()
        if let topic = topics?.first(where: { $0.topic == message.topic }) {
            appRouter.select(.notifications, with: .topicDetails(topic))
        }
    }
}

extension LiveMessagingService: MessagingDelegate {
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        NtfyLogger.messaging.debug("Received Firebase token: \(String(describing: fcmToken), privacy: .public)")

        // Received a new token, therefore we need to resubscribe for all topics
        subscribeToPollTopic()
        
        do {
            let topics = try store.topics()
            for topic in topics {
                subscribe(topic: topic)
            }
        } catch {
            NtfyLogger.messaging.error("Failure to fetch topics: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    private func subscribeToPollTopic() {
        NtfyLogger.messaging.debug("Subscribing to poll topic")
        Messaging.messaging().subscribe(toTopic: pollTopic)
    }
    
    private func subscribe(topic: TopicSubscription) {
        NtfyLogger.messaging.debug("Subscribing to topic: \(topic.subscriptionTopic, privacy: .public)")
        Messaging.messaging().subscribe(toTopic: topic.subscriptionTopic)
    }
}
