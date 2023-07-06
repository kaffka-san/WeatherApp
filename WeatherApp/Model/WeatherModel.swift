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
}

struct Main: Codable {
    let temp: Double
    let feelsLike: Double
}

struct Weather: Codable {
    let id: Int
    let description: String

}
