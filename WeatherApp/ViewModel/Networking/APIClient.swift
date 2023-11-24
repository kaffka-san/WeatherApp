//
//  APIClient.swift
//  Pokedex
//
//  Created by Anastasia Lenina on 03.11.2023.
//

/*
 * The following function is adapted from code provided by Applifting.
 * All rights reserved by Applifting.
 */

import Foundation

final class APIClient {
    // MARK: - Private properties

    private let session = URLSession.shared
    private let decoder = JSONDecoder()

    // MARK: - Public functions

    func requestVoid(
        for convertible: URLRequestConvertible

    ) async throws {
        _ = try await requestData(convertible)
    }

    func requestDecodable<T: Decodable>(
        for convertible: URLRequestConvertible
    ) async throws -> T {
        let (data, response) = try await requestData(convertible)
        return try decodeResponse(response, withData: data)
    }

    // MARK: - Private functions

    private func requestData(
        _ convertible: URLRequestConvertible
    ) async throws -> (Data, URLResponse) {
        let request = try await urlRequest(of: convertible)
        do {
            let (data, response) = try await session.data(for: request)
            if response.isFailure {
                throw APIError.badResponse
            }

            return (data, response)
        } catch {
            throw error
        }
    }

    private func decodeResponse<T: Decodable>(_: URLResponse, withData data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.parsing
        }
    }

    private func urlRequest(of convertible: URLRequestConvertible) async throws -> URLRequest {
        do {
            return try convertible.asURLRequest()
        } catch {
            throw APIError.badURL
        }
    }
}
