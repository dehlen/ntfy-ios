//
//  BasicAuthRequestModifier.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 16.01.26.
//

import Foundation

final class BasicAuthRequestModifier {
    let credentials: Credentials
    
    init(credentials: Credentials) {
        self.credentials = credentials
    }
}

extension BasicAuthRequestModifier: NetworkRequestModifier {
    func mutate(_ request: URLRequest) -> URLRequest {
        var modifiedRequest = request
        
        let data = Data("\(credentials.username):\(credentials.password)".utf8)
        let base64Credentials = data.base64EncodedString()
        
        modifiedRequest.setValue(
            "Basic \(base64Credentials)",
            forHTTPHeaderField: "Authorization"
        )

        return modifiedRequest
    }
}

