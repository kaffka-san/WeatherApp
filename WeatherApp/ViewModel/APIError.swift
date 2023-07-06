//
//  APIIError.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 02.07.2023.
//

import Foundation
enum APIError: Error {

    case badURL
    case badResponse(statusCode: Int)
    case url(URLError?)
    case parsing(DecodingError?)
    case unknown

   /* var description: String {
        switch self{
        case .badURL, .parsing, .unknown :
            return "Sorry, something went wrong."
        case .badResponse(statusCode: _):
            return "Sorry, the connection to our server failed"
        case .url(let error):
            return error?.localizedDescription ?? "Something went wrong"
        }
    }*/
    var localizedDescription: String {
        switch self {
        case .unknown: return "unknown error"
        case .badURL: return "invalid URL"
        case .url(let error):
            return error?.localizedDescription ?? "url session error"
        case .parsing(let error):
            return "parsing error \(error?.localizedDescription ?? "")"
        case .badResponse(statusCode: let statusCode):
            return "bad response with status code \(statusCode)"
        }
    }

}
