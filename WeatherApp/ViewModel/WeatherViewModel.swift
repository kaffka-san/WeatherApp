//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 29.06.2023.
//

import Foundation
import CoreLocation
import CoreLocationUI

class WeatherViewModel: NSObject, ObservableObject {
    let weatherAPI: WeatherAPI
    var urlWeather: String = ""
    var urlFullImg: String = ""

    var stateApp: StateApp {
        if isLoading || isLoadingImg {
            return .loading
        }
        if !isLocationAllowed && searchedText.isEmpty && weatherData.cityName.isEmpty {
            return .locationRestricted
        }
        if errorMessage != nil {
            return .error
        }
        if errorMessageImage != nil {
            return .loadData
        }
        if weatherData.cityName.isEmpty {
            return .empty
        } else {
            return .loadDataAndImage
        }
    }

    @Published var weatherData = WeatherData(
        cityName: "",
        countryName: "",
        temperature: "",
        iconName: "",
        humidity: "",
        pressure: "",
        feelsLike: "",
        description: ""
    )
    @Published var urlImg: String = ""
    @Published var isLoading: Bool = false
    @Published var isLoadingImg = false
    @Published var isLocationAllowed = false
    @Published var errorMessage: String?
    @Published var errorMessageImage: String?
    @Published var searchedText = ""
    var locationDataManager = LocationDataManager()

    init(weatherAPI: WeatherAPI) {
        self.weatherAPI = weatherAPI
        super.init()
        locationDataManager.onAuthStatusChanged = { [weak self] newStatus in
            self?.isLocationAllowed = newStatus == .authorizedAlways || newStatus == .authorizedWhenInUse
        }
    }

    @MainActor
    func getLocation() {
        weatherData =  WeatherData(
            cityName: "",
            countryName: "",
            temperature: "",
            iconName: "",
            humidity: "",
            pressure: "",
            feelsLike: "",
            description: ""
        )
        switch locationDataManager.locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            self.isLocationAllowed = true
            if let location = locationDataManager.locationManager.location?.coordinate {
                let locationCL = CLLocation(latitude: location.latitude, longitude: location.longitude)
                locationCL.fetchCityAndCountry { city, _, error in
                    guard let city = city, error == nil else { return }
                    self.getWeather(using: location)
                    self.getImageCity(cityName: city)
                }
            }
        case .restricted, .denied, .notDetermined:
            self.isLocationAllowed = false

        default:
            return
        }
    }

    @MainActor
    func getWeather(using coordinates: CLLocationCoordinate2D) {
        isLoading = true
        errorMessage = nil
        Task {  [weak self] in
            guard let self else { return }
            do {
                let weatherModel = try await weatherAPI.getWeather(coordinates: coordinates)
                update(weatherModel)
                isLoading = false
                searchedText = ""
            } catch let apiError as APIError {
                self.errorMessage = apiError.localisedDescription
                searchedText = ""
            }
        }
    }

    @MainActor
    func getWeather(using cityName: String) {
        isLoading = true
        errorMessage = nil
        Task {  [weak self] in
            guard let self else { return }
            do {
                let weatherModel = try await weatherAPI.getWeather(cityName: prepareString(cityName))
                update(weatherModel)
                isLoading = false
            } catch let apiError as APIError {
                self.errorMessage = apiError.localisedDescription
            }
        }
    }

    @MainActor
    func getImageCity(cityName: String) {
        isLoadingImg = true
        errorMessageImage = nil
        Task { [weak self] in
            guard let self else { return }
            do {
                let imageModel = try await weatherAPI.getImage(cityName: cityName)

                if  !imageModel.results.isEmpty {
                    self.urlImg = imageModel.results[0].urls["regular"] ?? ""
                }
                isLoadingImg = false
            } catch {
                isLoadingImg = false
                self.errorMessageImage = error.localizedDescription
            }
        }
    }

    func prepareString(_ string: String) -> String {
        return  string.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    @MainActor private func update(_ weatherModel: Weather) {
        weatherData = WeatherData(
            cityName: weatherModel.name,
            countryName: Locale.current.localizedString(forRegionCode: weatherModel.system.country)
            ?? weatherModel.system.country,
            temperature: String(format: "%.f°", weatherModel.main.temperature),
            iconName: getIcon(id: weatherModel.weather[0].id ),
            humidity: String(format: "%.f%%", weatherModel.main.humidity),
            pressure: String(format: "%.f hPa", weatherModel.main.pressure),
            feelsLike: String(format: "%.f°", weatherModel.main.feelsLike),
            description: weatherModel.weather[0].description.capitalized
        )
    }

    func getIcon(id: Int) -> String {
        switch id {
        case 200..<300: return WeatherIcon.storm.rawValue
        case 300..<400: return WeatherIcon.lightRain.rawValue
        case 500..<600: return WeatherIcon.rain.rawValue
        case 600..<700: return WeatherIcon.snow.rawValue
        case 700..<800: return WeatherIcon.fog.rawValue
        case 800: return WeatherIcon.sun.rawValue
        case 801..<900: return WeatherIcon.cloud.rawValue
        default: return WeatherIcon.empty.rawValue
        }
    }
}

enum WeatherIcon: String, CaseIterable {
    case storm = "cloud.bolt.rain.fill"
    case lightRain = "cloud.drizzle.fill"
    case rain = "cloud.rain.fill"
    case snow = "cloud.snow.fill"
    case fog = "cloud.fog.fill"
    case sun = "sun.max.fill"
    case cloud = "cloud.fill"
    case empty = ""
}

enum StateApp {
    case empty
    case loadData
    case loadDataAndImage
    case error
    case loading
    case locationRestricted
}

extension WeatherViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            self.isLocationAllowed = false

        case .authorizedAlways, .authorizedWhenInUse:
            self.isLocationAllowed = true

        @unknown default:
            break
        }
    }
}
