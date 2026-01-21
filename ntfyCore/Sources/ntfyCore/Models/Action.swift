//
//  Action.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 14.01.26.
//

import Foundation

public struct Action: Codable, Identifiable {
    public var id: String
    public var action: String
    public var label: String
    public var url: String?
    public var method: String?
    public var headers: [String: String]?
    public var body: String?
    public var clear: Bool?
}
