//
//  EmojiCoder.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 20.01.26.
//

import Foundation
import OSLog

public struct Emoji: Codable {
    public let emoji: String
    public let aliases: [String]
    public let tags: [String]

    public var unicode: String {
        emoji
    }
}

public final class EmojiCoder {
    public static let shared = EmojiCoder()

    private var cache: [String: Emoji] = [:]
    private let decoder: JSONDecoder = .init()

    private init() {
        load()
    }
    
    private func load() {
        do {
            let url = Bundle.module.url(forResource: "emojis", withExtension: "json")!
            let data = try Data(contentsOf: url)
            let result = try decoder.decode([Emoji].self, from: data)
            cache = Dictionary(
                uniqueKeysWithValues: result.flatMap { emoji in
                    emoji.aliases.map { alias in
                        (alias, emoji)
                    }
                }
            )
        } catch {
            NtfyLogger.emojis.error("Could not load emojis from local cache: \(error.localizedDescription, privacy: .public)")
        }
    }

    public func emoji(by alias: String) -> Emoji? {
        return cache[alias]
    }
}
