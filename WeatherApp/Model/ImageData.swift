//
//  ImageModel.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 30.06.2023.
//

import Foundation

struct ImageData: Codable {
    let results: [ResultImgae]
}
struct ResultImgae: Codable {
    let urls: [String: String]
}
