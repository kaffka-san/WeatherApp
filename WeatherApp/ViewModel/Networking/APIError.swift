//
//  APIIError.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 02.07.2023.
//

import Foundation
enum APIError: Error {
    case badURL
    case badResponse
    case url(URLError?)
    case parsing
    case unknown

    var localisedDescription: String {
        switch self {
        case .unknown: return "unknown error"
        case .badURL: return "invalid URL"
        case .url(let error):
            return error?.localizedDescription ?? "url session error"
        case .parsing:
            return "parsing error"
        case .badResponse:
            return "bad response"
        }
    }
}
