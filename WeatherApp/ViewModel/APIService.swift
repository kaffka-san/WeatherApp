//
//  APIService.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 02.07.2023.
//

import Foundation

struct ApiService {

    func fetchAsync<T: Decodable>(_ type: T.Type, url: String?) async throws -> T {

        guard let url = URL(string: url ?? "") else {
            print("T: error creating url \(type) url: \(String(describing: url))")
            throw APIError.badURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("T: error badResponse \(type)")
            throw APIError.badResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)

        }
        do {
            print("T: try Decoding \(type)")
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(type, from: data)
        } catch {
            print("error with api \(error)")
            throw APIError.parsing(error as? DecodingError)
        }
    }
}
