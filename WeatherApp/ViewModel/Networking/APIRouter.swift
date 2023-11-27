//
//  APIRouter.swift
//  Pokedex
//
//  Created by Anastasia Lenina on 03.11.2023.
//

import Foundation

protocol APIRouter: Router {
    var baseURLWeather: String { get }
    var baseUrlCityImage: String { get }
}

extension APIRouter {
    var baseURLWeather: String {
        "https://api.openweathermap.org/data/2.5/weather"
    }
    var baseUrlCityImage: String {
        "https://api.unsplash.com/search/photos"
    }
}
