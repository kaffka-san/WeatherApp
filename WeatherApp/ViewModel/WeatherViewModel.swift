//
//  WeatherManager.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 29.06.2023.
//

import Foundation
import CoreLocation
import CoreLocationUI
enum StateApp {
    case empty
    case loadData
    case loadDataAndImage
    case error
    case loading
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
    var stateApp: StateApp {
        if errorMessage == nil && isLoading && isLoadingImg && urlWeather.isEmpty {
            print("Empty")
            return StateApp.empty
        } else if errorMessage != nil {
            print("error")
            return StateApp.error
        } else if  (isLoading || isLoadingImg) && errorMessage == nil {
            print("loading")
            return StateApp.loading
        } else if !isLoadingImg && !isLoading && errorMessage == nil && errorMessageImage != nil {
            print("data loaded")
            return StateApp.loadData
        } else if !urlImg.isEmpty && !weatherData.cityName.isEmpty && errorMessage == nil && errorMessageImage == nil {
            print("all loaded")
            return StateApp.loadDataAndImage
        }
        return StateApp.empty
    }

    let service = ApiService()

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
            print("Default case of getting location")
            return
        }

    }

    var urlWeather: String = ""
    var urlFullImg: String = ""

    func prepareString(str: String) -> String {
        let trimmedStr = str.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let encodedTrimmedStr = trimmedStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return encodedTrimmedStr
        }
        return ""
    }
    func createImgUrl(cityNameSearched: String) {
//        let cityWord = "city street"
//        let combineSearch = "\(cityNameSearched) \(cityWord)"
        let combineSearch = "\(cityNameSearched)"
        let cityPrepared = prepareString(str: combineSearch)
        urlFullImg = "https://api.unsplash.com/search/photos?query=\(cityPrepared)&client_id=gFleRQgTSJRjceXWzsxPJHnPXwiA-iec1UzHY_Mz9wE"
        print("urlImg: \(urlFullImg)")
    }
    func createUrl(cityNameSearched: String) {
        let apiKey = "0dd9c31dbb4daf81bf91fa90977cefd3"
        let url = "https://api.openweathermap.org/data/2.5/weather?q="
        let cityPrepared = prepareString(str: cityNameSearched)
        urlWeather = "\(url + cityPrepared)&&appid=\(apiKey)&units=metric"
        print("url weather: \(urlWeather)")
    }
    func getWeatherFromLocation(for coordinates: CLLocationCoordinate2D) {
        let apiKey = "0dd9c31dbb4daf81bf91fa90977cefd3"
        let url = "https://api.openweathermap.org/data/2.5/weather?"
        urlWeather = "\(url)lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&&appid=\(apiKey)&units=metric"
    }
    @MainActor
    func fetchAsync() {
        isLoading = true
        errorMessage = nil
        Task(priority: .medium) {
            do {

                let weatherModel = try await self.service.fetchAsync(WeatherModel.self, url: self.urlWeather)
                isLoading = false
                self.weatherData = WeatherData(cityName: weatherModel.name,
                                               countryName: Locale.current.localizedString(forRegionCode: weatherModel.sys.country) ?? weatherModel.sys.country,
                                               temp: String(format: "%.f°", weatherModel.main.temp),
                                               iconName: self.getIcon(id: weatherModel.weather[0].id ),
                                               humidity: String(format: "%.f", weatherModel.main.humidity),
                                               pressure: String(format: "%.f", weatherModel.main.pressure),
                                               feelsLike: String(format: "%.f°", weatherModel.main.feelsLike),
                                               description: weatherModel.weather[0].description.capitalized)
                print("city name: \(weatherData.cityName)")
                print("original description : \(weatherData.description)")
                print("description \(weatherData.iconName)")
                print("___________________________")
            } catch let apiError as APIError {
                print(" !!!!!!!!! error: \(apiError)")
                self.errorMessage = apiError.localizedDescription

            }
        }
    }
    @MainActor
    func fetchAsyncImg() {
        isLoadingImg = true
        errorMessageImage = nil
        Task(priority: .medium) {
            do {
                let imageModel = try await service.fetchAsync(ImageModel.self, url: urlFullImg)
                isLoadingImg = false
                if  !imageModel.results.isEmpty {
                    self.urlImg = imageModel.results[0].urls["regular"] ?? ""
                }
                print("actual umage url is: \(self.urlImg)")
            } catch {
                print("!!!!!!!!!!! error img: \(String(describing: error.localizedDescription))")
                self.errorMessageImage = error.localizedDescription
            }

        }
    }
    @MainActor
    func getData(using cityNameSearched: String, coordinates: CLLocationCoordinate2D? = nil) {
        if let coordinates {
            getWeatherFromLocation(for: coordinates)
        } else {
            createUrl(cityNameSearched: cityNameSearched)
        }
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

// https://api.openweathermap.org/data/2.5/weather?q=London&&appid=0dd9c31dbb4daf81bf91fa90977cefd3
// api.teleport.org/api/urban_areas/slug:london/images/
// https://api.unsplash.com/photos/?page=1&query=london&client_id=gFleRQgTSJRjceXWzsxPJHnPXwiA-iec1UzHY_Mz9wE
// ?page=1&query=london
// https://api.unsplash.com/search/photos?query=new%20york&client_id=gFleRQgTSJRjceXWzsxPJHnPXwiA-iec1UzHY_Mz9wE
