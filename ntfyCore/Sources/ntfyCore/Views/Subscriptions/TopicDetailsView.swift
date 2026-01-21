//
//  TopicDetailsView.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 12.01.26.
//

import OSLog
import SwiftData
import SwiftUI

struct TopicDetailsView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dependencies) private var dependencies: DependencyContainer

    private var testNotificationPublisher: any TestNotificationPublisher {
        dependencies.testNotificationPublisher
    }
    
    private var store: any Store {
        dependencies.store
    }

    @State private var selectedNotifications: Set<Notification.ID> = []
    @State var editMode: EditMode = .inactive
    
    @Query(
        sort: \Notification.timestamp,
        order: .reverse,
        animation: .default
    ) var notifications: [Notification]

    let subscription: TopicSubscription
    
    init(subscription: TopicSubscription) {
        self.subscription = subscription
        
        let topicID = subscription.id
        _notifications = Query(
            filter: #Predicate { $0.topic.id == topicID },
            sort: [SortDescriptor(\Notification.timestamp, order: .reverse)],
            animation: .default
        )
    }
    
    var body: some View {
        List(notifications, selection: $selectedNotifications) { notification in
            NotificationRow(notification: notification)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        delete(notification: notification)
                    }
                }
        }
        .overlay {
            if notifications.isEmpty {
                emptyView
            }
        }
        .navigationTitle(subscription.topic)
        .toolbar {
            toolbar
        }
        .environment(\.editMode, $editMode)
        .refreshable {
            await refresh()
        }
        .task(id: subscription.id) {
            await refresh()
        }
    }
    
    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        if editMode == .inactive {
            ToolbarItem(placement: .primaryAction) {
                Menu("Topic Options", systemImage: "ellipsis.circle") {
                    Button("Select notifications") {
                        setEditMode(isEnabled: true)
                    }
                    .disabled(notifications.isEmpty)
                    
                    Button("Send test notification") {
                        publishTestNotification()
                    }
                    
                    Button("Clear all notifications", role: .destructive) {
                        clearAllNotifications()
                    }
                    .disabled(notifications.isEmpty)
                    
                    Button("Unsubscribe", role: .destructive) {
                        unsubscribe()
                    }
                }
            }
        } else {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    setEditMode(isEnabled: false)
                }
            }
            
            ToolbarItem(placement: .bottomBar) {
                Button("Delete \(selectedNotifications.count) notifications", systemImage: "trash", role: .destructive) {
                    deleteSelectedNotifications()
                }
                .disabled(selectedNotifications.isEmpty)
            }
        }
    }
    
    private var emptyView: some View {
        ContentUnavailableView(
            "You haven't received any notifications for this topic yet.",
            systemImage: "bell.slash",
            description: Text("To send notifications to this topic, simply PUT or POST to the topic URL.\n\nExample:\n`$ curl -d \"hi\" \(subscription.serviceURL)/\(subscription.topic)`\n\nDetailed instructions are available on [ntfy.sh](https://ntfy.sh) and [in the docs](https://ntfy.sh/docs).")
        )
    }
    
    private func refresh() async {
        do {
            _ = try await dependencies.store.pollNotifications(for: subscription)
        } catch {
            NtfyLogger.db.error("Failed to poll notifications for subscription: \(error.localizedDescription, privacy: .public)")
        }
    }
    
    private func setEditMode(isEnabled: Bool) {
        withAnimation {
            self.editMode = isEnabled ? .active : .inactive
        }
    }
    
    private func publishTestNotification() {
        Task {
            do {
                try await testNotificationPublisher.publish(
                    to: subscription
                )
                await refresh()
            } catch {
                NtfyLogger.messaging.error("Failure to send test notification: \(error.localizedDescription, privacy: .public)")
            }
        }
    }
    
    private func clearAllNotifications() {
        do {
            let subscriptionID = subscription.id
            try context.delete(model: Notification.self, where: #Predicate { $0.topic.id == subscriptionID })
        } catch {
            NtfyLogger.db.error("Failed to delete notifications for topic: \(subscription.topic, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }
    
    private func unsubscribe() {
        context.delete(subscription)
        dismiss()
    }
    
    private func delete(notification: Notification) {
        context.delete(notification)
    }
    
    private func deleteSelectedNotifications() {
        do {
            let selectedNotificationIDs = selectedNotifications
            try context.delete(
                model: Notification.self,
                where: #Predicate { selectedNotificationIDs.contains($0.id) }
            )
        } catch {
            NtfyLogger.db.error("Could not delete selected notifications: \(error.localizedDescription, privacy: .public)")
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: TopicSubscription.self, Notification.self,
            configurations: config
        )
        let preview = TopicSubscription(
            topic: "preview",
            serviceURL: "https://ntfy.sh"
        )
        return TopicDetailsView(subscription: preview)
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}

