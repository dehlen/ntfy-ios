//
//  NotificationsView.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 12.01.26.
//

import SwiftData
import SwiftUI

struct NotificationsView: View {
    @Environment(AppRouter.self) private var appRouter
    @Environment(\.modelContext) private var context
    
    @Query(sort: \TopicSubscription.topic, order: .forward) private var subscriptions: [TopicSubscription]
    
    var body: some View {
        @Bindable var appRouter = appRouter

        NavigationStack(path: $appRouter.notificationsRouter.path) {
            List {
                Section {
                    NavigationLink(value: AppRoute.allNotifications) {
                        DetailRow(
                            headline: "All notifications",
                            subheadline: lastNotificationDate()?.formattedRelativeDateTime()
                        )
                        .badge(allNotificationsCount)
                    }
                }
                
                Section("Topics") {
                    ForEach(subscriptions) { subscription in
                        NavigationLink(value: AppRoute.topicDetails(subscription)) {
                            SubscriptionRow(subscription: subscription)
                                .badge(subscription.notifications?.count ?? 0)
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Notifications")
            .navigationDestination(for: AppRoute.self, destination: { route in
                route.destination
            })
            .toolbar {
                toolbar
            }
        }
    }
    
    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("Add subscription", systemImage: "plus") {
                self.appRouter.present(.addSubscription)
            }
        }
    }
    
    private var allNotificationsCount: Int {
        let descriptor = FetchDescriptor<Notification>()
        return (try? context.fetchCount(descriptor)) ?? 0
    }
    
    private func lastNotificationDate() -> Date? {
        var descriptor = FetchDescriptor<Notification>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first?.date
    }
    
    private func delete(indexSet: IndexSet) {
        indexSet.forEach { index in
            let subscription = subscriptions[index]
            context.delete(subscription)
        }
    }
}

#Preview {
    NotificationsView()
}
