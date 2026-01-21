//
//  Priority.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 16.01.26.
//

import Foundation
public import UserNotifications

public enum Priority: Int, Codable, CaseIterable {
    case min = 1
    case low = 2
    case `default` = 3
    case high = 4
    case max = 5
    
    public var interruptionLevel: UNNotificationInterruptionLevel {
        switch self {
        case .min:
            .passive
        case .low:
            .passive
        case .default:
            .active
        case .high:
            .timeSensitive
        case .max:
            .critical
        }
    }
    
    public var relevanceScore: Double {
        switch self {
        case .min:
            0
        case .low:
            0.25
        case .default:
            0.5
        case .high:
            0.75
        case .max:
            1
        }
    }
}
