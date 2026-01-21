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
    func applicationDidFinishLaunching(_ application: UIApplication) {
        CompositionRoot.messagingService.configure()
        
        Task {
            await CompositionRoot.messagingService.enableRemoteNotifications(for: application)
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        CompositionRoot.messagingService.updateDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        NtfyLogger.messaging.error("Failed to register for remote notifications: \(error.localizedDescription, privacy: .public)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        return await CompositionRoot.messagingService.handleRemoteNotification(userInfo: userInfo)
    }
}
