//
//  URLRequestBuilder.swift
//  ntfy
//
//  Created by von Knobelsdorff, David on 16.01.26.
//

import Foundation

class URLRequestBuilder {
    let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func get(_ requestPath: String, contentType: ContentType = .json) -> URLRequest {
        URLRequest(url: baseURL).path(requestPath).method(.get).contentType(contentType)
    }

    func post(_ requestPath: String, contentType: ContentType = .json) -> URLRequest {
        URLRequest(url: baseURL).path(requestPath).method(.post).contentType(contentType)
    }

    func put(_ requestPath: String) -> URLRequest {
        URLRequest(url: baseURL).path(requestPath).method(.put)
    }

    func delete(_ requestPath: String) -> URLRequest {
        URLRequest(url: baseURL).path(requestPath).method(.delete)
    }
}

extension URLRequest {
    func path(_ path: String) -> URLRequest {
        var request = self
        request.url = url?.appending(path: path)
        return request
    }

    func method(_ method: HTTPMethod) -> URLRequest {
        var request = self
        request.httpMethod = method.rawValue
        return request
    }

    func body(json body: any Encodable, encoder: JSONEncoder = JSONEncoder()) -> URLRequest {
        var request = self
        request.httpBody = try? encoder.encode(body)
        return request.contentType(.json)
    }
    
    func body(data: Data) -> URLRequest {
        var request = self
        request.httpBody = data
        return request
    }

    func queryItems(_ items: [String: String]) -> URLRequest {
        let urlQueryItems = items.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        return queryItems(urlQueryItems)
    }

    func queryItems(_ queryItems: [URLQueryItem]) -> URLRequest {
        var request = self
        request.url = url?.appending(queryItems: queryItems)
        return request
    }

    func contentType(_ contentType: ContentType) -> URLRequest {
        setValue(contentType.rawValue, forHeader: "Content-Type")
    }

    func setValue(_ value: String, forHeader header: String) -> URLRequest {
        var request = self
        request.setValue(value, forHTTPHeaderField: header)
        return request
    }

    func withCachePolicy(_ policy: URLRequest.CachePolicy) -> URLRequest {
        var request = self
        request.cachePolicy = policy
        return request
    }
}

extension URLRequest {
    func basicAuth(credentials: Credentials?) -> URLRequest {
        guard let credentials else {
            return self
        }
        let modifier = BasicAuthRequestModifier(credentials: credentials)
        return modifier.mutate(self)
    }
}
