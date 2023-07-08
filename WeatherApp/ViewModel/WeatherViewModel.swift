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

    @Published var cityName: String = ""
    @Published var temp: String = ""
    @Published var iconName: String = ""
    @Published var feelsLike: String = ""
    @Published var urlImg: String = ""
    @Published var isLoading: Bool = false
    @Published var isLoadingImg = false
    @Published var errorMessage: String?
    @Published var errorMessageImage: String?

    let service = ApiService()
    func getIcon(id: Int) -> String {
        switch id {
        case 200..<300: return "cloud.bolt.rain.fill"
        case 300..<400: return "cloud.drizzle.fill"
        case 500..<600: return "cloud.rain.fill"
        case 600..<700: return "cloud.snow.fill"
        case 700..<800: return "cloud.fog.fill"
        case 800: return "sun.max.fill"
        case 801..<900: return"cloud.fill"
        default: return ""
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
        let cityWord = "city"
        let combineSearch = "\(cityNameSearched) \(cityWord)"
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
    func getWeatherFromLocation(for coordinats: CLLocationCoordinate2D) {
        let apiKey = "0dd9c31dbb4daf81bf91fa90977cefd3"
        let url = "https://api.openweathermap.org/data/2.5/weather?"
        urlWeather = "\(url)lat=\(coordinats.latitude)&lon=\(coordinats.longitude)&&appid=\(apiKey)&units=metric"
    }
    @MainActor
    func fetchAsync() {
        isLoading = true
        errorMessage = nil
        Task(priority: .medium) {
            do {

                let weatherModel = try await service.fetchAsync(WeatherModel.self, url: urlWeather)
                isLoading = false
                self.cityName = weatherModel.name
                print("city name: \(weatherModel.name)")
                self.temp = String(format: "%.f°", weatherModel.main.temp)
                print("original description : \(weatherModel.weather[0].description)")
                self.iconName = self.getIcon(id: weatherModel.weather[0].id )
                print("description \(self.iconName)")
                self.feelsLike = String(weatherModel.main.feelsLike)
                print("___________________________")

            } catch let apiError as APIError {
                print("trying error: \(apiError)")
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
                self.urlImg = imageModel.results[0].urls["regular"] ?? "monstera"
                print("actual umage url is: \(self.urlImg)")
            } catch {
                self.errorMessageImage = error.localizedDescription
                print("trying error img: \(String(describing: error.localizedDescription))")
            }
        }
    }
    @MainActor
    func getData(using cityNameSearched: String, coordinats: CLLocationCoordinate2D? = nil) {
        if let coordinatsSafe = coordinats {
            getWeatherFromLocation(for: coordinatsSafe)
        } else {
            createUrl(cityNameSearched: cityNameSearched)
        }
        createImgUrl(cityNameSearched: cityNameSearched)
        fetchAsync()
        fetchAsyncImg()
        isLoading = true

    }

    /*func fetchImg(){
        errorMessageImage = nil
        isLoadingImg = true
        service.fetch(ImageModel.self, url: urlImg) { result in
            print("Fetch img _______________")
            DispatchQueue.main.async {
                switch result{
                case .failure(let error):
                    self.errorMessageImage = error.localizedDescription
                    print("error fetch img \(error) ")
                    print(self.urlImg)
                case .success(let imageModel):
                    self.urlImg = imageModel.results[0].urls["regular"] ?? "monstera"
                    print("fetching img was successful \(self.urlImg)")
                }
                self.isLoadingImg = false
                print("___________________________")
            }
        }
    }
    func fetch() {
        isLoading = true
        errorMessage = nil
        service.fetch(WeatherModel.self, url: urlWeather) { result in
            DispatchQueue.main.async{
                print("Fetch weather _______________")
                switch result {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    print("error fetch weather: \(error.localizedDescription)")
                    print("error fetch weather description: \(error.description)")
                case .success(let weatherModel):
                    self.cityName = weatherModel.name
                    print("city name: \(weatherModel.name)")
                    self.temp = String(format: "%.f°", weatherModel.main.temp)
                    print("original description : \(weatherModel.weather[0].description)")
                    self.iconName = self.getIcon(id: weatherModel.weather[0].id )
                    print("description \(self.iconName)")
                    self.feelsLike = String(weatherModel.main.feels_like)
                    print("___________________________")
                }
                self.isLoading = false
            }
        }
    }*/
}

// https://api.openweathermap.org/data/2.5/weather?q=London&&appid=0dd9c31dbb4daf81bf91fa90977cefd3
// api.teleport.org/api/urban_areas/slug:london/images/
// https://api.unsplash.com/photos/?page=1&query=london&client_id=gFleRQgTSJRjceXWzsxPJHnPXwiA-iec1UzHY_Mz9wE
// ?page=1&query=london
// https://api.unsplash.com/search/photos?query=new%20york&client_id=gFleRQgTSJRjceXWzsxPJHnPXwiA-iec1UzHY_Mz9wE
