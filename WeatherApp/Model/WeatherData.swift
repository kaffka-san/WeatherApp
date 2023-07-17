//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 10.07.2023.
//

import Foundation

struct WeatherData {
    var cityName: String
    var countryName: String
    var temp: String
    var iconName: String
    var humidity: String
    var preassure: String
    var feelsLie: String
    var description: String
}

// class WeatherDataContainer: ObservableObject {
//    @Published var weatherDataContainer : WeatherData
//    init(weatherDataContainer: WeatherData) {
//        self.weatherDataContainer = weatherDataContainer
//    }
// }
