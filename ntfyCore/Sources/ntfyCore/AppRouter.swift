//
//  AppRouter.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 12.01.26.
//

import Foundation
import Observation
public import SwiftUI

public enum AppTab: Int, Hashable, Equatable, CaseIterable, Identifiable {
    case notifications
    case settings
    
    public var id: Self { self }
    
    public var title: String {
        switch self {
        case .notifications:
            NSLocalizedString("Notifications", comment: "")
        case .settings:
            NSLocalizedString("Settings", comment: "")
        }
    }
    
    public var systemImage: String {
        switch self {
        case .notifications:
            "bubble"
        case .settings:
            "gear"
        }
    }
    
    @ViewBuilder public var destination: some View {
        switch self {
        case .notifications:
            NotificationsView()
        case .settings:
            SettingsView()
        }
    }
}

public enum AppRoute: Hashable, Equatable, Identifiable {
    case addSubscription
    case allNotifications
    case topicDetails(TopicSubscription)
    case editDefaultServer
    case addUser
    case editUser(User)
    
    public var id: Self { self }
    
    @ViewBuilder public var destination: some View {
        switch self {
        case .addSubscription:
           AddSubscriptionForm()
        case .allNotifications:
            AllNotificationsView()
        case let .topicDetails(subscription):
            TopicDetailsView(subscription: subscription)
        case .editDefaultServer:
            EditDefaultServerView()
        case .addUser:
            AddUserForm()
        case let .editUser(user):
            EditUserForm(user: user)
        }
    }
}

public protocol Router: Observable {
    var selectedTab: AppTab { get set }
    var presented: AppRoute? { get set }
    
    func present(_ route: AppRoute)
    func push(_ route: AppRoute)
    func select(_ tab: AppTab, with route: AppRoute)
}

@Observable @MainActor public final class AppRouter: Router {
    public var selectedTab: AppTab = .notifications
    public var presented: AppRoute?
    
    public var notificationsRouter = NotificationsRouter()
    public var settingsRouter = SettingsRouter()
    
    public init() {}

    public func present(_ route: AppRoute) {
        presented = route
    }
    
    public func push(_ route: AppRoute) {
        switch selectedTab {
        case .notifications:
            notificationsRouter.path.append(route)
        case .settings:
            settingsRouter.path.append(route)
        }
    }
    
    public func select(_ tab: AppTab, with route: AppRoute) {
        self.selectedTab = tab
        self.set(route: route)
    }
    
    private func set(route: AppRoute) {
        switch selectedTab {
        case .notifications:
            notificationsRouter.path = [route]
        case .settings:
            settingsRouter.path = [route]
        }
    }
}

@Observable @MainActor public final class NotificationsRouter {
    public var path: [AppRoute] = []
}

@Observable @MainActor public final class SettingsRouter {
    public var path: [AppRoute] = []
}
