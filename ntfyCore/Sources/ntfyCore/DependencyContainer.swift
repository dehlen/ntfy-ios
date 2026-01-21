//
//  DependencyContainer.swift
//  ntfyCore
//
//  Created by von Knobelsdorff, David on 21.01.26.
//

import Foundation
public import SwiftData
public import SwiftUI

@MainActor
@Observable
public final class DependencyContainer {
    /// Shared instance for global access (AppDelegate, NotificationService, etc.)
    public static let live: DependencyContainer = .init()

    public let userStore: any UserStore
    public let appRouter: AppRouter
    public let apiService: any APIService
    public let store: any Store
    public let messagingService: any MessagingService
    public let testNotificationPublisher: any TestNotificationPublisher

    public var modelContainer: ModelContainer { store.container }

    public init(
        userStore: any UserStore,
        apiService: any APIService,
        store: any Store,
        messagingService: any MessagingService,
        testNotificationPublisher: any TestNotificationPublisher,
        appRouter: AppRouter
    ) {
        self.userStore = userStore
        self.apiService = apiService
        self.store = store
        self.messagingService = messagingService
        self.testNotificationPublisher = testNotificationPublisher
        self.appRouter = appRouter
    }

    public convenience init() {
        let userStore = LiveUserStore()
        let appRouter = AppRouter()
        let apiService = LiveAPIService(userStore: userStore)
        let store = LiveStore(apiService: apiService)
        let messagingService = LiveMessagingService(store: store, appRouter: appRouter)
        let testNotificationPublisher = LiveTestNotificationPublisher(apiService: apiService)

        self.init(
            userStore: userStore,
            apiService: apiService,
            store: store,
            messagingService: messagingService,
            testNotificationPublisher: testNotificationPublisher,
            appRouter: appRouter
        )
    }
}

// MARK: - Environment Support

extension EnvironmentValues {
    @Entry public var dependencies: DependencyContainer = .live
}
