//
//  NotificationRow.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 16.01.26.
//

import SwiftData
import SwiftUI

struct NotificationRow: View {
    let notification: ntfyCore.Notification
    
    var body: some View {
        DetailRow(
            headline: notification.title ?? "\(notification.topic.serviceURLHost)/\(notification.topic.topic)",
            subheadline: notification.message
        )
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: ntfyCore.Notification.self,
            configurations: config
        )
        let previewTopic = TopicSubscription(
            topic: "preview",
            serviceURL: "https://ntfy.sh"
        )
        let preview = Notification(
            title: "Notification Title",
            message: "Notification Message",
            timestamp: Date.now.timeIntervalSince1970,
            priority: .default,
            click: nil,
            tags: nil,
            actions: nil,
            messageID: UUID().uuidString,
            topic: previewTopic
        )
        return NotificationRow(notification: preview)
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}

