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

    @Published var weatherData = WeatherData(cityName: "",
                                             countryName: "",
                                             temp: "",
                                             iconName: "",
                                             humidity: "",
                                             pressure: "",
                                             feelsLike: "",
                                             description: "")

    @Published var urlImg: String = ""
    @Published var isLoading: Bool = false
    @Published var isLoadingImg = false
    @Published var errorMessage: String?
    @Published var errorMessageImage: String?
    @Published var alertItem: AlertItem?
    @Published var locationDataManager = LocationDataManager()

    var urlWeather: String = ""
    var urlFullImg: String = ""

    var stateApp: StateApp {
        if errorMessage == nil && isLoading && isLoadingImg && urlWeather.isEmpty {
         //   print("StateApp: Empty")
            return StateApp.empty
        } else if errorMessage != nil {
         //   print("StateApp: error")
            return StateApp.error
        } else if  (isLoading || isLoadingImg) && (errorMessage == nil && errorMessageImage == nil) {
         //   print("StateApp: loading")
            return StateApp.loading
        } else if !isLoadingImg && !isLoading && errorMessage == nil && (errorMessageImage != nil) {
          //  print("StateApp: data loaded")
            return StateApp.loadData
        } else if !isLoadingImg && !isLoading && errorMessage == nil && errorMessageImage == nil && !urlWeather.isEmpty {
          //  print("StateApp: all loaded")
            return StateApp.loadDataAndImage
        }
        return StateApp.empty
    }

    let service = NetworkManager()

    @MainActor
    func getLocation() {
        switch locationDataManager.locationManager.authorizationStatus {
        case .authorizedWhenInUse:  // Location services are available.
            if let location = locationDataManager.locationManager.location?.coordinate {
                let locationCL = CLLocation(latitude: location.latitude, longitude: location.longitude)
                locationCL.fetchCityAndCountry { city, country, error in
                    guard let city = city, let country = country, error == nil else { return }
                    print("\(city), \(country)")  // Rio de Janeiro, Brazil
                    self.getData(using: city, coordinates: location)
                }
            }
        case .restricted, .denied:  // Location services currently unavailable.
            alertItem = AlertContext.locationRestricted
        case .notDetermined:        // Authorisation not determined yet.
            alertItem = AlertContext.locationNotDetermined
        default:
            return
        }
    }

    func prepareString(str: String) -> String {
        let trimmedStr = str.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let encodedTrimmedStr = trimmedStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return trimmedStr
        }
        return ""
    }
    func createImgUrl(cityNameSearched: String) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.unsplash.com"
        components.path = "/search/photos"
        let apiKey = URLQueryItem(name: "client_id", value: "gFleRQgTSJRjceXWzsxPJHnPXwiA-iec1UzHY_Mz9wE")
        let cityPrepared = prepareString(str: cityNameSearched)
        let city = URLQueryItem(name: "query", value: cityPrepared)
        let page = URLQueryItem(name: "page", value: "1")
        components.queryItems = [apiKey, city, page]
        if let url = components.string {
            urlFullImg = url
            print("imageURL: \(urlFullImg)")
        }
    }
    func createUrlWeather (cityNameSearched: String? = "", coordinates: CLLocationCoordinate2D? = nil ) {

        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
        let apiKey = URLQueryItem(name: "appid", value: "0dd9c31dbb4daf81bf91fa90977cefd3")
        let units = URLQueryItem(name: "units", value: "metric")
        if let cityNameSearched {
            let cityPrepared = prepareString(str: cityNameSearched)
            let city = URLQueryItem(name: "q", value: cityPrepared)
            components.queryItems = [city, apiKey, units]
        }
        if let coordinates {
            let lon = URLQueryItem(name: "lon", value: String(coordinates.longitude))
            let lat = URLQueryItem(name: "lat", value: String(coordinates.latitude))
            components.queryItems = [lat, lon, apiKey, units]
        }

        if let urlString = components.string {
            print("weather url: \(urlWeather)")
            urlWeather = urlString
        }
    }

    @MainActor
    func fetchAsync() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let weatherModel = try await NetworkManager.shared.fetchData(Weather.self, url: self.urlWeather)
                isLoading = false
                self.weatherData = WeatherData(cityName: weatherModel.name,
                                               countryName: Locale.current.localizedString(forRegionCode: weatherModel.system.country)
                                               ?? weatherModel.system.country,
                                               temp: String(format: "%.f°", weatherModel.main.temperature),
                                               iconName: self.getIcon(id: weatherModel.weather[0].id ),
                                               humidity: String(format: "%.f%%", weatherModel.main.humidity),
                                               pressure: String(format: "%.f hPa", weatherModel.main.pressure),
                                               feelsLike: String(format: "%.f°", weatherModel.main.feelsLike),
                                               description: weatherModel.weather[0].description.capitalized)
            } catch let apiError as APIError {
                self.errorMessage = apiError.localisedDescription
                print("error get weather data \(String(describing: self.errorMessage))")

            }
        }
    }
    @MainActor
    func fetchAsyncImg() {
        isLoadingImg = true
        errorMessageImage = nil
        Task {
            do {
                let imageModel = try await NetworkManager.shared.fetchData(ImageData.self, url: urlFullImg)
                isLoadingImg = false
                if  !imageModel.results.isEmpty {
                    self.urlImg = imageModel.results[0].urls["regular"] ?? ""
                }
            } catch {
                isLoadingImg = false
                print("error get image \( error.localizedDescription )")
                self.errorMessageImage = error.localizedDescription
            }
        }
    }
    @MainActor
    func getData(using cityNameSearched: String, coordinates: CLLocationCoordinate2D? = nil) {
        createUrlWeather(cityNameSearched: cityNameSearched, coordinates: coordinates)
        createImgUrl(cityNameSearched: cityNameSearched)
        fetchAsync()
        fetchAsyncImg()
        isLoading = true

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
}
// https://api.openweathermap.org/data/2.5/weather?q=London&&appid=0dd9c31dbb4daf81bf91fa90977cefd3
// api.teleport.org/api/urban_areas/slug:london/images/
// https://api.unsplash.com/photos/?page=1&query=london&client_id=gFleRQgTSJRjceXWzsxPJHnPXwiA-iec1UzHY_Mz9wE
// ?page=1&query=london
// https://api.unsplash.com/search/photos?query=new%20york&client_id=gFleRQgTSJRjceXWzsxPJHnPXwiA-iec1UzHY_Mz9wE
