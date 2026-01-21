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
    
    @Relationship(deleteRule: .cascade, inverse: \Notification.topic)
    public var notifications: [Notification]?
        
    public init(id: String = UUID().uuidString, topic: String, serviceURL: String) {
        self.id = id
        self.topic = topic
        self.serviceURL = serviceURL
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
        if serviceURL == Bundle.main.appBaseUrl {
            topic
        } else {
            "\(serviceURL)/\(topic)"
        }
    }
    
    @Transient
    public var lastNotificationId: String? {
        notifications?.max(by: {
            $0.timestamp < $1.timestamp
        })?.messageID
    }
}
