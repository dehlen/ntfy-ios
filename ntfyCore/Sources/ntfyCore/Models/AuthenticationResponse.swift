//
//  AuthenticationResponse.swift
//  ntfyCore
//
//  Created by von Knobelsdorff, David on 21.01.26.
//

import Foundation

public struct AuthenticationResponse: Codable {
    public var success: Bool?
    public var code: Int?
    public var http: Int?
    public var error: String?
}
