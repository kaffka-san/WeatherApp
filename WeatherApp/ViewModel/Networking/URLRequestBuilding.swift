//
//  URLRequestBuilding.swift
//  Pokedex
//
//  Created by Anastasia Lenina on 03.11.2023.
//

/*
 * The following function is adapted from code provided by Applifting.
 * All rights reserved by Applifting.
 */

import Foundation

/// HTTP method definitions.
///
/// See https://tools.ietf.org/html/rfc7231#section-4.3
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
    case patch = "PATCH"
}

/// A dictionary of headers to apply to a `URLRequest`.
public typealias HTTPHeaders = [String: String]

/// Types adopting the `URLConvertible` protocol can be used to construct URLs, which are then used to construct
/// URL requests.
public protocol URLConvertible {
    /// Returns a URL that conforms to RFC 2396 or throws an `Error`.
    ///
    /// - throws: An `Error` if the type cannot be converted to a `URL`.
    ///
    /// - returns: A URL or throws an `Error`.
    func asURL() throws -> URL
}

extension URL: URLConvertible {
    public func asURL() throws -> URL { self }
}

extension String: URLConvertible {
    public func asURL() throws -> URL {
        if let url = URL(string: self) {
            return url
        } else {
            throw URLError(.badURL)
        }
    }
}

/// Types adopting the `URLRequestConvertible` protocol can be used to construct URL requests.
public protocol URLRequestConvertible {
    /// Returns a URL request or throws if an `Error` was encountered.
    ///
    /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
    ///
    /// - returns: A URL request.
    func asURLRequest() throws -> URLRequest
}

extension URLRequest: URLRequestConvertible {
    public func asURLRequest() throws -> URLRequest { self }
}

struct URLRequestBuilder {
    let method: HTTPMethod
    let url: URLConvertible
    let headers: HTTPHeaders
    let body: () throws -> Data?
}

extension URLRequestBuilder: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        var request = try URLRequest(url: url.asURL())
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = try body()
        return request
    }
}
