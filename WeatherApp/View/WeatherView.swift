//
//  WeatherView.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 29.06.2023.
//

import Foundation
import SwiftUI
import UIKit

struct WeatherView: View {
    @StateObject var weatherViewModel: WeatherViewModel
    @ObservedObject private var autocomplete = AutocompleteObject()
    @State private var isSearchFocused = false

    init(weatherViewModel: WeatherViewModel) {
        _weatherViewModel = StateObject(wrappedValue: weatherViewModel)
        configNavigationBar()
    }

    var body: some View {
        NavigationStack {
            content
                .accentColor(.white)
                .onAppear {
                    weatherViewModel.getLocation()
                }
                .onChange(of: weatherViewModel.locationDataManager.authorizationStatus) { _, _ in
                    weatherViewModel.getLocation()
                }
                .onChange(of: weatherViewModel.searchedText) { _, _ in
                    weatherViewModel.errorMessage = nil
                    weatherViewModel.errorMessageImage = nil
                    weatherViewModel.isLoading = false
                    weatherViewModel.isLoadingImg = false
                    autocomplete.autocomplete(weatherViewModel.searchedText)
                }
                .searchable(text: $weatherViewModel.searchedText, isPresented: $isSearchFocused)
                .searchSuggestions({
                    ForEach(autocomplete.suggestions, id: \.self) { suggestion in
                        Text(suggestion)
                            .searchCompletion(suggestion)
                    }
                })
                .onSubmit(of: [.text, .search]) {
                    weatherViewModel.getWeather(using: weatherViewModel.searchedText)
                    weatherViewModel.getImageCity(cityName: weatherViewModel.searchedText)
                    isSearchFocused = false
                    autocomplete.suggestions = []
                    weatherViewModel.errorMessage = nil
                    weatherViewModel.errorMessageImage = nil
                }
                .refreshable {
                    weatherViewModel.getLocation()
                }

        }
        .ignoresSafeArea(.keyboard)
        .preferredColorScheme(.dark)
    }
}

private extension WeatherView {
    var content: some View {
        ZStack {
            switch weatherViewModel.stateApp {
            case .loadData, .loadDataAndImage, .empty:
                scrollView
            case .error:
                ErrorView(errorMessage: weatherViewModel.errorMessage ?? "Unexpected error has occurred")
            case .loading:
                ProgressView()

            case .locationRestricted:
                allowLocationView
            }
        }
    }

    var scrollView: some View {
        Group {
            if !weatherViewModel.weatherData.cityName.isEmpty {
                ScrollView {
                    weatherData
                }
                .scrollIndicators(.hidden)
                .background {
                    backgroundImage
                        .ignoresSafeArea()
                }
                .ignoresSafeArea(.keyboard)
                .edgesIgnoringSafeArea(.horizontal)
                .transition(.opacity.animation(.easeInOut(duration: 0.8)))
            } else {
               Rectangle()
                    .fill(Color.black)
                    .ignoresSafeArea()
            }
        }
    }

    var backgroundImage: some View {
        AsyncImage(url: URL(string: weatherViewModel.urlImg)) { image in
            ZStack {
                image.image?
                    .resizable()
                    .scaledToFill()
                Rectangle().fill(Color.darkPurple.gradient.opacity(0.3).blendMode(.multiply))
            }
            .frame(width: UIScreen.main.bounds.width)
            .ignoresSafeArea()
            .ignoresSafeArea(.keyboard)
            .brightness(-0.2)
        }
    }

    var cityLabel: some View {
        Text(weatherViewModel.weatherData.cityName)
            .foregroundColor(.white)
            .font(.largeTitle)
            .lineLimit(1)
            .minimumScaleFactor(0.4)
            .multilineTextAlignment(.center)
            .padding(.vertical, 6)
            .padding(.horizontal, 16)
    }

    var countryLabel: some View {
        Text(weatherViewModel.weatherData.countryName)
            .foregroundColor(.white)
            .font(.system(size: 25, weight: .thin))
            .multilineTextAlignment(.center)
    }

    var temperatureValueIcon: some View {
        HStack {
            Image(systemName: weatherViewModel.weatherData.iconName)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .padding()
            Text(weatherViewModel.weatherData.temperature)
                .foregroundColor(.white)
                .font(.system(size: 70, weight: .thin))
                .padding()
        }
        .frame(maxWidth: .infinity)
    }

    var cityCard: some View {
        VStack {
            cityLabel
            countryLabel
            temperatureValueIcon
        }
        .padding(.vertical, UIScreen.main.bounds.height * 0.03)
        .backgroundBlur(radius: 15, opaque: true)
        .background(Color.darkPurple.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 40))
        .padding(.horizontal, 36)
        .padding(.bottom, 60)
        .padding(.top, 10)
    }

    var textLabel: some View {
        Text(weatherViewModel.weatherData.description)
            .foregroundColor(.white)
            .font(.system(size: 20, weight: .thin))
            .padding(.bottom, 20)
    }

    var getLocationButton: some View {
        Button {
            weatherViewModel.getLocation()
        }
    label: {
        HStack {
            Text("Current location")
            Image(systemName: "location.circle.fill")
        }
        .frame(width: 250, height: 50)
        .backgroundBlur(radius: 25, opaque: true)
        .background(Color.lightPurple.gradient.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 40))
        .foregroundColor(.white)
        .padding(.bottom, 40)
    }
    }

    var allowLocationButton: some View {
        Button {
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }
    label: {
        HStack {
            Text("Allow location")
            Image(systemName: "location.circle.fill")
        }
        .frame(width: 250, height: 50)
        .backgroundBlur(radius: 25, opaque: true)
        .background(Color.lightPurple.gradient.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 40))
        .foregroundColor(.white)
        .padding(.bottom, 40)
    }
    }

    var allowLocationView: some View {
        ZStack {
            Rectangle()
                .fill(Color.darkPurple.gradient)
                .ignoresSafeArea()

            VStack {
                Spacer()
                Text("This app requires your location to provide data")
                    .padding(.vertical, 20)
                    .padding(.horizontal, 6)
                    .font(.headline)
                    .frame(height: 100, alignment: .leading)
                    .frame(maxWidth: .infinity)
                Image(systemName: "location.magnifyingglass")
                    .resizable()
                    .foregroundColor(.white.opacity(0.2))
                    .scaledToFit()
                    .frame(width: 380, height: 380)
                    .offset(x: 70, y: 0)
                allowLocationButton
            }
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(.keyboard)
        }
    }

    var statisticsCard: some View {
        VStack(spacing: 0) {
            weatherInfo
                .padding(.top, 20)
            Spacer()
            textLabel
            Spacer()
            getLocationButton
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.4)
        .padding(.bottom, 20)
        .backgroundBlur(radius: 6, opaque: true)
        .background(Color.darkPurple.opacity(0.2))
        .cornerRadius(30)
    }
    var weatherData: some View {
        // Main Weather Data
        ZStack {
            VStack(spacing: 0) {
                cityCard
                Spacer()
                statisticsCard
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    private var weatherInfo: some View {
        HStack(spacing: 5) {
            RectangleIcon(
                imageName: "thermometer.medium",
                textInput: weatherViewModel.weatherData.feelsLike,
                textTitle: "Feels like"
            )
            RectangleIcon(
                imageName: "humidity",
                textInput: weatherViewModel.weatherData.humidity,
                textTitle: "Humidity"
            )
            RectangleIcon(
                imageName: "gauge.medium",
                textInput: weatherViewModel.weatherData.pressure,
                textTitle: "Pressure"
            )
        }
        .padding(20)
    }

    func configNavigationBar() {
        UINavigationBar.appearance().barTintColor = .clear
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView(
            weatherViewModel: WeatherViewModel(
                weatherAPI: WeatherAPI(
                    apiClient: APIClient(),
                    router: WeatherRouter()
                )
            )
        ).preferredColorScheme(.dark)
    }
}
