//
//  NetworkingExtensions.swift
//  Pokedex
//
//  Created by Anastasia Lenina on 03.11.2023.
//

import Foundation

extension Result {
    var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }

    var error: Error? {
        switch self {
        case .success: return nil
        case let .failure(error): return error
        }
    }
}

extension URLResponse {
    var httpStatusCode: Int {
        (self as? HTTPURLResponse)?.statusCode ?? 0
    }

    var isSuccess: Bool {
        let successRange = 200..<300
        return successRange.contains(httpStatusCode)
    }

    var isFailure: Bool {
        !isSuccess
    }
}
