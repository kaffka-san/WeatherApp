//
//  Alert.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 10.07.2023.
//

import SwiftUI

struct AlertItem: Identifiable {
 let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
}

struct AlertContext {
    static let locationRestricted = AlertItem(title: Text("Location Error"),
                                    message: Text("Current location data was restricted or denied."),
                                              dismissButton: .default(Text("Got it")))
    static let locationNotDeremined = AlertItem(title: Text("Location Error"),
                                                message: Text("Can't get your location."),
                                                          dismissButton: .default(Text("Got it")))
}
