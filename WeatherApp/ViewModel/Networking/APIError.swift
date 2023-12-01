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
        case .unknown: return "We're sorry, an unexpected error has occurred."
        case .badURL: return "Invalid URL Detected"
        case .url(let error):
            return error?.localizedDescription ?? "url session error"
        case .parsing:
            return "Parsing Error"
        case .badResponse:
            // swiftlint:disable:next line_length
            return "We're sorry, but we couldn't find the city you're looking for. Please check your spelling and try again."
        }
    }
}
