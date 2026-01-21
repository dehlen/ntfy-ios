//
//  AllNotificationsView.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 14.01.26.
//

import OSLog
import SwiftData
import SwiftUI

struct AllNotificationsView: View {
    @Environment(\.dependencies) private var dependencies: DependencyContainer
    @Environment(\.modelContext) private var context

    @Query(sort: \Notification.timestamp, order: .reverse) var notifications: [Notification]

    @State private var selectedNotifications: Set<Notification.ID> = []
    @State var editMode: EditMode = .inactive
    
    var store: any Store {
        dependencies.store
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
        .navigationTitle("All notifications")
        .toolbar {
            toolbar
        }
        .environment(\.editMode, $editMode)
        .refreshable {
            await refresh()
        }
        .task {
            await refresh()
        }
    }
    
    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        if editMode == .inactive {
            ToolbarItem(placement: .primaryAction) {
                Menu("Options", systemImage: "ellipsis.circle") {
                    Button("Select notifications") {
                        withAnimation {
                            self.editMode = .active
                        }
                    }
                    .disabled(notifications.isEmpty)

                    Button("Clear all notifications", role: .destructive) {
                        clearAllNotifications()
                    }
                    .disabled(notifications.isEmpty)
                }
            }
        } else {
            ToolbarItem(placement: .confirmationAction) {
                Button(role: .confirm) {
                    withAnimation {
                        self.editMode = .inactive
                    }
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
            description: Text("To send notifications to this topic, simply PUT or POST to the topic URL.\n\nExample:\n`$ curl -d \"hi\" ntfy.sh/<topic name>`\n\nDetailed instructions are available on [ntfy.sh](https://ntfy.sh) and [in the docs](https://ntfy.sh/docs).")
        )
    }
    
    private func refresh() async {
        await withTaskGroup(of: Void.self) { group in
            for subscription in (try? store.topics()) ?? [] {
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
    
    private func clearAllNotifications() {
        do {
            try context.delete(model: Notification.self)
        } catch {
            NtfyLogger.db.error("Failed to delete notifications: \(error.localizedDescription, privacy: .public)")
        }
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
            for: Notification.self,
            configurations: config
        )

        return AllNotificationsView()
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}

