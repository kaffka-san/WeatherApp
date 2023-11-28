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
    @State var searchedText = ""
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
                .searchable(text: $searchedText, isPresented: $isSearchFocused)
                .searchSuggestions({
                    ForEach(autocomplete.suggestions, id: \.self) { suggestion in
                        Text(suggestion)
                            .searchCompletion(suggestion)
                    }
                })
                .onSubmit(of: [.text, .search]) {
                    weatherViewModel.getWeather(using: searchedText)
                    weatherViewModel.getImageCity(cityName: searchedText)
                    isSearchFocused = false
                    autocomplete.suggestions = []
                    weatherViewModel.errorMessage = nil
                    weatherViewModel.errorMessageImage = nil
                }
                .onChange(of: searchedText) { _, _ in
                    weatherViewModel.errorMessage = nil
                    weatherViewModel.errorMessageImage = nil
                    weatherViewModel.isLoading = false
                    weatherViewModel.isLoadingImg = false
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
            case .loadData, .loadDataAndImage:
                scrollView
            case .error:
                ErrorView(errorMessage: weatherViewModel.errorMessage ?? "Unexpected error has occurred")
            case .loading:
                ProgressView()
            case .empty:
                Text("")
            }
        }
    }

    var scrollView: some View {
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
        .alert(item: $weatherViewModel.alertItem) { alertItem in
            Alert(title: alertItem.title,
                  message: alertItem.message,
                  dismissButton: alertItem.dismissButton)
        }
        .transition(.opacity.animation(.easeInOut(duration: 0.8)))
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
            .font(.system(size: 40, weight: .regular))
            .multilineTextAlignment(.center)
            .padding(.vertical, 5)
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
    var statisticsCard: some View {
        VStack(spacing: 0) {
            weatherInfo
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
            .onChange(of: searchedText) { _, _ in
                autocomplete.autocomplete(searchedText)
            }
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
