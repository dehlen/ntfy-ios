//
//  ActionCoder.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 16.01.26.
//

import Foundation
import OSLog

public struct ActionCoder {
    private static let supportedActions = ["view", "http"]

    public static func parse(_ actions: String?) -> [Action]? {
        guard let actions = actions, !actions.isEmpty else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let data = Data(actions.utf8)
            return try decoder.decode([Action].self, from: data)
                .filter {
                    supportedActions.contains($0.action)
                }
        } catch {
            NtfyLogger.actions.error("Unable to parse actions: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
    
    public static func encode(_ actions: [Action]?) -> String? {
        guard let actions = actions else {
            return nil
        }
        let encoder = JSONEncoder()
        let data = try? encoder.encode(actions)
        return data.flatMap {
            String(data: $0, encoding: .utf8)
        }
    }
}
