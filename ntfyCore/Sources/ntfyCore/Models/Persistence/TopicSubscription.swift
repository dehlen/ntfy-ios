//
//  TopicSubscription.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 13.01.26.
//

public import Foundation
public import SwiftData

@Model
public class TopicSubscription: Identifiable {
    #Unique<TopicSubscription>([\.id], [\.topic, \.serviceURL])
    
    public var id: String = UUID().uuidString
    public var topic: String
    public var serviceURL: String
    public var lastNotificationId: String?

    @Relationship(deleteRule: .cascade, inverse: \Notification.topic)
    public var notifications: [Notification]?
        
    public init(
        id: String = UUID().uuidString,
        topic: String,
        serviceURL: String,
        lastNotificationId: String? = nil
    ) {
        self.id = id
        self.topic = topic
        self.serviceURL = serviceURL
        self.lastNotificationId = lastNotificationId
    }
    
    @Transient
    public var serviceURLHost: String {
        guard
            let url = URL(string: serviceURL),
            let host = url.host()
        else {
            return serviceURL
        }
        
        return host
    }
    
    @Transient
    public var subscriptionTopic: String {
        if serviceURL == AppConfiguration.appBaseUrl {
            topic
        } else {
            "\(serviceURL)/\(topic)"
        }
    }
}
