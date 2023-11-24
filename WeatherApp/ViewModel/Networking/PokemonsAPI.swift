//
//  WeatherAPI.swift
//  Pokedex
//
//  Created by Anastasia Lenina on 04.11.2023.
//

import Foundation
import CoreLocation

protocol WeatherAPIProtocol {
    func getWeather(coordinates: CLLocationCoordinate2D) async throws -> Weather
    func getWeather(cityName: String) async throws -> Weather
    func getImage(cityName: String) async throws -> ImageData
}

final class WeatherAPI: WeatherAPIProtocol, Service {
   // typealias Route = WeatherRoute

    private let apiClient: APIClient
    let router: any Router<WeatherRoute>

    init(
        apiClient: APIClient,
        router: any Router<WeatherRoute>
    ) {
        self.apiClient = apiClient
        self.router = router
    }

    func getWeather(coordinates: CLLocationCoordinate2D) async throws -> Weather {
        let route = WeatherRoute.weatherWithCoordinates(coordinates: coordinates)
        return try await apiClient.requestDecodable(
            for: urlConvertible(for: route)
        )
    }

    func getWeather(cityName: String) async throws -> Weather {
        let route = WeatherRoute.weatherWithCityName(cityName: cityName)
        return try await apiClient.requestDecodable(
            for: urlConvertible(for: route)
        )
    }

    func getImage(cityName: String) async throws -> ImageData {
        let route = WeatherRoute.cityImage(cityName: cityName)
        return try await apiClient.requestDecodable(
            for: urlConvertible(for: route)
        )
    }
}
