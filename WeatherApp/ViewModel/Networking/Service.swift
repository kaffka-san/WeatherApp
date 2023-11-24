//
//  Service.swift
//  Pokedex
//
//  Created by Anastasia Lenina on 03.11.2023.
//

/*
 * The following function is adapted from code provided by Applifting.
 * All rights reserved by Applifting.
 */

import Foundation

/// General service definition
protocol Service: AnyObject {
    associatedtype Route
    /// Router to translate associated enum Route into URLRequests.
    ///
    /// Example of potential `init` implementation to enable Router associated type erasure.
    ///
    /// ```
    ///    init(_ router: some Router<Route>, authorizing: Authorizing?) where R.Route == Self.Route {
    ///        self.router = router
    ///    }
    /// ```
    var router: any Router<Route> { get }
}

extension Service {
    /// - Wraps route and router into RouteToURLConvertor which implements URLRequestConvertible.
    /// - Meant for use with Alamofire to leverage its error handling.
    func urlConvertible(for route: Route) -> URLRequestConvertible {
        RouteToURLConvertor(route: route, router: router)
    }
}

/// Wrapper around URLRequest creation to be able to leverage APIClient's error handling
/// instead of handling in every service.
private struct RouteToURLConvertor<Route>: URLRequestConvertible {
    private let route: Route
    private let router: any Router<Route>

    init(route: Route, router: some Router<Route>) {
        self.route = route
        self.router = router
    }

    func asURLRequest() throws -> URLRequest {
        try router.urlRequest(for: route).asURLRequest()
    }
}
