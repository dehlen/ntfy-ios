//
//  NotificationsView.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 12.01.26.
//

import OSLog
import SwiftData
import SwiftUI

struct NotificationsView: View {
    @Environment(\.dependencies) private var dependencies: DependencyContainer
    @Environment(\.modelContext) private var context
    
    @Query(
        sort: \TopicSubscription.topic,
        order: .forward,
        animation: .default
    ) private var subscriptions: [TopicSubscription]
    
    var body: some View {
        @Bindable var appRouter = dependencies.appRouter

        NavigationStack(path: $appRouter.notificationsRouter.path) {
            List {
                Section {
                    NavigationLink(value: AppRoute.allNotifications) {
                        VStack(alignment: .leading) {
                            Text("All notifications")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            if let lastNotificationDate = lastNotificationDate()?.formattedRelativeDateTime() {
                                Text(lastNotificationDate)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .badge(allNotificationsCount)
                    }
                }
                
                Section("Topics") {
                    ForEach(subscriptions) { subscription in
                        NavigationLink(value: AppRoute.topicDetails(subscription)) {
                            SubscriptionRow(subscription: subscription)
                                .badge(notificationsCount(for: subscription))
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
            .refreshable {
                await refresh()
            }
            .task(id: subscriptions) {
                await refresh()
            }
        }
    }
    
    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button("Add subscription", systemImage: "plus") {
                dependencies.appRouter.present(.addSubscription)
            }
        }
    }
    
    private var allNotificationsCount: Int {
        let descriptor = FetchDescriptor<Notification>()
        return (try? context.fetchCount(descriptor)) ?? 0
    }
    
    private func notificationsCount(for subscription: TopicSubscription) -> Int {
        let subscriptionID = subscription.id
        let descriptor = FetchDescriptor<Notification>(predicate: #Predicate {
            $0.topic.id == subscriptionID
        })
        return (try? context.fetchCount(descriptor)) ?? 0
    }
    
    private func lastNotificationDate() -> Date? {
        var descriptor = FetchDescriptor<Notification>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first?.date
    }
    
    private func refresh() async {
        await withTaskGroup(of: Void.self) { group in
            for subscription in subscriptions {
                group.addTask { @Sendable @MainActor in
                    do {
                        _ = try await dependencies.store.pollNotifications(for: subscription)
                    } catch {
                        NtfyLogger.db.error("Failed to poll notifications for subscription: \(error.localizedDescription, privacy: .public)")
                    }
                }
            }
        }
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
