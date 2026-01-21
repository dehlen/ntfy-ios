//
//  User.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 13.01.26.
//

public import Foundation

public struct User: Identifiable, Hashable, Equatable, Sendable {
    public let id: String
    public let serviceURL: String
    public let username: String

    public init(id: String = UUID().uuidString, serviceURL: String, username: String) {
        self.id = id
        self.serviceURL = serviceURL
        self.username = username
    }

    public static let preview: User = .init(
        serviceURL: "https://ntfy.sh",
        username: "dvk"
    )
}
