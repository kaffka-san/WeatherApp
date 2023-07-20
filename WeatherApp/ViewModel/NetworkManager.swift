//
//  APIService.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 02.07.2023.
//

import Foundation
import SwiftUI

final class NetworkManager {
    static let shared = NetworkManager()
    private let cache = NSCache<NSString, UIImage>()

    func fetchWeather<T> (url: String?) async throws -> T {

        guard let url = URL(string: url ?? "") else {
            print("T: error creating url \(type) url: \(String(describing: url))")
            throw APIError.badURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("error badResponse")
            throw APIError.badResponse(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)

        }
        do {
            print("try Decoding ")
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(WeatherModel.self, from: data)
        } catch {
            print("error with api \(error)")
            throw APIError.parsing(error as? DecodingError)
        }
    }

    func downloadImage(fromUrlString urlString: String, completed: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: urlString)
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
        }
        guard let url = URL(string: urlString) else {
            completed(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, _ in
            guard let data, let image = UIImage(data: data) else {
                completed(nil)
                return
            }
            self.cache.setObject(image, forKey: cacheKey)
            completed(image)
        }
        task.resume()
    }
}
