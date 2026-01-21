//
//  ntfyApp.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 12.01.26.
//

import ntfyCore
import SwiftData
import SwiftUI

@main
struct ntfyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    
    var body: some Scene {
        WindowGroup {
            AppTabBar()
                .environment(CompositionRoot.appRouter)
                .environment(CompositionRoot.userStore)
                .environment(CompositionRoot.testNotificationPublisher)
        }
        .modelContainer(CompositionRoot.store.container)
    }
}
