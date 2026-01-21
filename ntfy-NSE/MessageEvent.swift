//
//  MessageEvent.swift
//  ntfy-NSE
//
//  Created by von Knobelsdorff, David on 21.01.26.
//

import Foundation

enum MessageEvent: String {
    case pollRequest = "poll_request"
    case message = "message"
}
