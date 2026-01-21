//
//  NetworkRequestModifier.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 16.01.26.
//

import Foundation

protocol NetworkRequestModifier {
    func mutate(_ request: URLRequest) -> URLRequest
}
