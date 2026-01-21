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
    @Environment(\.openURL) private var openURL
    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 16.0

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if notification.priority != .default {
                    Image("priority-\(notification.priority.rawValue)", bundle: .module)
                        .resizable()
                        .scaledToFit()
                        .frame(width: iconSize, height: iconSize)
                }
                Text(notification.date.formattedRelativeDateTime())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let title = notification.title {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)

            if !notification.viewActions.isEmpty {
                actionButtons
            }
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        let actions = notification.viewActions

        if actions.count > 2 {
            Menu {
                ForEach(actions) { action in
                    Button(action.label) {
                        handleAction(action)
                    }
                }
            } label: {
                Label("Actions", systemImage: "ellipsis.circle")
            }
            .buttonStyle(.borderless)
            .font(.body)
        } else {
            HStack {
                if let first = actions.first {
                    Button(first.label) {
                        handleAction(first)
                    }
                }

                if actions.count == 2 {
                    Spacer()
                    Button(actions[1].label) {
                        handleAction(actions[1])
                    }
                }
            }
        }
    }
    
    var message: String {
        let emojis = notification.availableTags.compactMap({ EmojiCoder.shared.emoji(by: $0)?.unicode }).joined(separator: "")

        if !emojis.isEmpty {
            return "\(emojis) \(notification.message)"
        } else {
            return notification.message
        }
    }

    private func handleAction(_ action: Action) {
        guard
            let urlString = action.url,
            let url = URL(string: urlString) else {
            return
        }

        openURL(url)
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

        let actions = """
        [
            {
                "id": "1",
                "action": "view",
                "label": "Open Docs",
                "url": "https://docs.ntfy.sh",
                "clear": true
            },
            {
                "id": "2",
                "action": "view",
                "label": "Open Website",
                "url": "https://ntfy.sh",
                "clear": true
            }
        ]    
        """
        
        let preview = Notification(
            title: "Notification Title",
            message: "Notification Message",
            timestamp: Date.now.timeIntervalSince1970,
            priority: .low,
            click: nil,
            tags: "tada",
            actions: actions,
            messageID: UUID().uuidString,
            topic: previewTopic
        )
        return NotificationRow(notification: preview)
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}

