//
//  APIService.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 02.07.2023.
//

import Foundation
struct ApiService {
    // @MainActor

    func fetch<T: Decodable>(_ type: T.Type, url: String?, completion: @escaping(Result<T, APIError>) -> Void) {
        guard let url = URL(string: url ?? "") else {
            let error = APIError.badURL
            print("APIError.badURL: \(error)")
            completion(Result.failure(error))
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error as? URLError {
                print("its URLError")
                completion(Result.failure(APIError.url(error)))
            } else if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
                completion(Result.failure(APIError.badResponse(statusCode: response.statusCode)))
                print("its badResponse")
            } else if let data = data {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do {
                    let result = try decoder.decode(type, from: data)
                    completion(Result.success(result))
                } catch {
                    completion(Result.failure(APIError.parsing(error as? DecodingError)))
                }
            }

        }
        task.resume()
    }
    func fetchAsync<T: Decodable>(_ type: T.Type, url: String?) async throws -> T {

        guard let url = URL(string: url ?? "") else {
            print("T: error creating url \(type) url: \(url)")
            throw APIError.badURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("T: error badResponse \(type)")
            throw APIError.badResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)

        }
        do {
            print("T: try Decodong \(type)")
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase

           return try decoder.decode(type, from: data)
        } catch {
            print("error with api \(error)")
            throw APIError.parsing(error as? DecodingError)

        }

    }
}
