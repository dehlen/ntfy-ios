//
//  NtfyLogger.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 16.01.26.
//

import Foundation
public import OSLog

public struct NtfyLogger {
    public static let actions: Logger = .init(category: "actions")
    public static let db: Logger = .init(category: "db")
    public static let messaging: Logger = .init(category: "messaging")
    public static let userStore: Logger = .init(category: "userStore")
    public static let network: Logger = .init(category: "network")
    public static let emojis: Logger = .init(category: "emojis")
    public static let nse: Logger = .init(category: "nse")
}

extension Logger {
    init(category: String) {
        self.init(subsystem: Bundle.main.bundleIdentifier!, category: category)
    }
}
