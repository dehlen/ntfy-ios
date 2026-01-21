//
//  AppDelegate.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 16.01.26.
//

import ntfyCore
import OSLog
import SwiftUI

@MainActor
class AppDelegate: NSObject, UIApplicationDelegate {
    private var dependencies: DependencyContainer {
        DependencyContainer.live
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        dependencies.messagingService.configure()

        Task {
            await dependencies.messagingService.enableRemoteNotifications(for: application)
        }
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        dependencies.messagingService.updateDeviceToken(deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        NtfyLogger.messaging.error("Failed to register for remote notifications: \(error.localizedDescription, privacy: .public)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        return await dependencies.messagingService.handleRemoteNotification(userInfo: userInfo)
    }
}
