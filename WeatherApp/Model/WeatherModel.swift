//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 29.06.2023.
//

import Foundation
struct WeatherModel: Codable {

    let main: Main
    let name: String
    let weather: [Weather]
    let sys: Sys
}
struct Main: Codable {
    let temp: Double
    let feelsLike: Double
    let pressure: Double
    let humidity: Double
}
struct Coord: Codable {
    let lon: Double
    let lat: Double
}
struct Sys: Codable {
    let country: String
}
struct Weather: Codable {
    let id: Int
    let description: String

}
