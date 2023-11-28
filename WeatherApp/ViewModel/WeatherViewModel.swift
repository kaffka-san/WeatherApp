//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 29.06.2023.
//

import Foundation
import CoreLocation
import CoreLocationUI

class WeatherViewModel: ObservableObject {
    let service = NetworkManager()
    let weatherAPI: WeatherAPI
    var urlWeather: String = ""
    var urlFullImg: String = ""

    var stateApp: StateApp {
        if !isLocationAllowed {
            print("location restricted")
            return .locationRestricted
        }
        if errorMessage != nil {
            print("error state")
            return .error
        }
        if isLoading || isLoadingImg {
            print("loading state")
            return .loading
        }
        if errorMessageImage != nil {
            print("load data state")
            return .loadData
        }
        if weatherData.cityName.isEmpty {
            print("empty state")
            return .empty
        } else {
            print("data and image state")
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
    @Published var alertItem: AlertItem?
    @Published var locationDataManager = LocationDataManager()

    init(weatherAPI: WeatherAPI) {
        self.weatherAPI = weatherAPI
    }

    @MainActor
    func getLocation() {
        switch locationDataManager.locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            if let location = locationDataManager.locationManager.location?.coordinate {
                let locationCL = CLLocation(latitude: location.latitude, longitude: location.longitude)
                locationCL.fetchCityAndCountry { city, _, error in
                    guard let city = city, error == nil else { return }
                    self.getWeather(using: location)
                    self.getImageCity(cityName: city)
                    self.isLocationAllowed = true
                }
            }
        case .restricted, .denied:
            alertItem = AlertContext.locationRestricted
            self.isLocationAllowed = false
        case .notDetermined:
            alertItem = AlertContext.locationNotDetermined
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
            } catch let apiError as APIError {
                print("error VM \(apiError.localisedDescription)")
                self.errorMessage = apiError.localisedDescription
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
                print("error VM \(apiError.localisedDescription)")
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
                    print("imgUrl \(self.urlImg)")
                }
                isLoadingImg = false
            } catch {
                isLoadingImg = false
                print("error get image \(error.localizedDescription)")
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
        print(weatherData)
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
// https://api.openweathermap.org/data/2.5/weather?q=London&&appid=0dd9c31dbb4daf81bf91fa90977cefd3
// api.teleport.org/api/urban_areas/slug:london/images/
// https://api.unsplash.com/photos/?page=1&query=london&client_id=gFleRQgTSJRjceXWzsxPJHnPXwiA-iec1UzHY_Mz9wE
// ?page=1&query=london
// https://api.unsplash.com/search/photos?query=new%20york&client_id=gFleRQgTSJRjceXWzsxPJHnPXwiA-iec1UzHY_Mz9wE
