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

    func fetchData <T: Decodable>(_ type: T.Type, url: String?) async throws -> T {

        guard let url = URL(string: url ?? "") else {
            print("T: error creating url \(type) url: \(String(describing: url))")
            throw APIError.badURL
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            print("T: error badResponse \(type)")
            throw APIError.badResponse

        }
        do {
            print("try Decoding \(type)")
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            print("error with api \(error)")
            throw APIError.parsing
        }
    }

    func downloadImage(fromUrlString urlString: String, completed: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: urlString)
        if let image = cache.object(forKey: cacheKey) {
            completed(image)
        }
        guard let url = URL(string: urlString) else {
            print("async img failed bad url")
            completed(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data, let image = UIImage(data: data) else {
                print("async img failed \(String(describing: error))")
                completed(nil)
                return
            }
            self.cache.setObject(image, forKey: cacheKey)
            completed(image)
        }
        task.resume()
    }
}
