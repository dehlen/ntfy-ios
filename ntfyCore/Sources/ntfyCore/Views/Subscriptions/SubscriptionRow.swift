//
//  SubscriptionRow.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 13.01.26.
//

import SwiftData
import SwiftUI

struct SubscriptionRow: View {
    @Environment(\.modelContext) private var context

    let subscription: TopicSubscription

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(subscription.serviceURLHost)/\(subscription.topic)")
                .font(.headline)
                .foregroundStyle(.primary)
            if let lastNotificationDate = lastNotificationDate(for: subscription)?.formattedRelativeDateTime() {
                Text(lastNotificationDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func lastNotificationDate(for topic: TopicSubscription) -> Date? {
        let topicID = topic.id
        var descriptor = FetchDescriptor<Notification>(
            predicate: #Predicate { $0.topic.id == topicID },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first?.date
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: TopicSubscription.self,
            configurations: config
        )
        let preview = TopicSubscription(
            topic: "preview",
            serviceURL: "https://ntfy.sh"
        )
        return SubscriptionRow(subscription: preview)
            .modelContainer(container)
    } catch {
        fatalError("Failed to create model container.")
    }
}
