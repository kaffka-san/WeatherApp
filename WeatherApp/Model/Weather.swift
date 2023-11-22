//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 29.06.2023.
//

import Foundation

struct Weather: Codable {
    let main: Main
    let name: String
    let weather: [Description]
    let system: System

    enum CodingKeys: String, CodingKey {
        case main
        case name
        case weather
        case system = "sys"
    }
}

struct Main: Codable {
    let temperature: Double
    let feelsLike: Double
    let pressure: Double
    let humidity: Double

    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case feelsLike
        case pressure
        case humidity
    }
}

struct Coord: Codable {
    let longitude: Double
    let latitude: Double

    enum CodingKeys: String, CodingKey {
        case longitude = "lon"
        case latitude = "lat"
    }
}

struct System: Codable {
    let country: String
}

struct Description: Codable {
    let id: Int
    let description: String
}
