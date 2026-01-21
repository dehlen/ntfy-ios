//
//  CompositionRoot.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 16.01.26.
//

import Foundation
import ntfyCore
import SwiftUI

@MainActor enum CompositionRoot {
    static var apiService: some APIService {
        LiveAPIService(userStore: userStore)
    }
    
    static var messagingService: some MessagingService {
        LiveMessagingService(
            store: store,
            appRouter: appRouter
        )
    }

    static var store: Store {
        LiveStore(
            apiService: apiService
        )
    }

    static var testNotificationPublisher: TestNotificationPublisher {
        LiveTestNotificationPublisher(apiService: apiService)
    }
    
    static let userStore: UserStore = LiveUserStore()
    static let appRouter: Router = AppRouter()
}
