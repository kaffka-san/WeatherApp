//
//  PokemonsDataRouter.swift
//  Pokedex
//
//  Created by Anastasia Lenina on 04.11.2023.
//

import Foundation
import CoreLocation

enum WeatherRoute {
    case weatherWithCoordinates(coordinates: CLLocationCoordinate2D)
    case weatherWithCityName(cityName: String)
    case cityImage(cityName: String)
}

final class WeatherRouter: Router, APIRouter {
    private let headers = [
        "Content-Type": "application/json",
        "accept": "application/json"
    ]
    private let weatherApiKey = "0dd9c31dbb4daf81bf91fa90977cefd3"
    private let imageCityApiKey = "gFleRQgTSJRjceXWzsxPJHnPXwiA-iec1UzHY_Mz9wE"

    func urlRequest(for route: WeatherRoute) -> URLRequestConvertible {
        switch route {
        case let .weatherWithCoordinates(coordinates):
            return buildRequest(
                method: .get,
                // swiftlint:disable:next line_length
                url: "\(baseURLWeather)?appid=\(weatherApiKey)&units=metric&lon=\(coordinates.longitude)&lat=\(coordinates.latitude)",
                headers: headers,
                body: { nil }
            )
        case let .weatherWithCityName(cityName):
            return buildRequest(
                method: .get,
                url: "\(baseURLWeather)?q=\(cityName)&appid=\(weatherApiKey)&units=metric",
                headers: headers,
                body: { nil }
            )
        case let .cityImage(cityName):
            return buildRequest(
                method: .get,
                url: "\(baseUrlCityImage)?query=\(cityName)%20city&client_id=\(imageCityApiKey)",
                headers: headers,
                body: { nil }
            )
        }
    }
}
