//
//  WeatherView.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 29.06.2023.
//

import Foundation
import SwiftUI
import Combine
import UIKit

struct WeatherView: View {
    @StateObject var weatherViewModel = WeatherViewModel()
    @State var animationOpacity: Double = 0.0
    @State private var triggerValue: Bool = false
    @State var searchedText = ""
    @ObservedObject private var autocomplete = AutocompleteObject()
    @Environment(\.dismissSearch) var dismissSearch

    init() {
        configNavigationBar()
    }

    var body: some View {
        NavigationStack {
            content
                .accentColor(.white)
                .onAppear {
                    weatherViewModel.getLocation()
                }
                .searchable(
                    text: $searchedText,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    suggestions: {
                        ForEach(autocomplete.suggestions, id: \.self) { suggestion in
                            Text(suggestion)
                                .searchCompletion(suggestion)
                        }
                    }
                )
                .onSubmit(of: .search) {
                    weatherViewModel.getData(using: searchedText)
                    hideKeyboard()
                    searchedText = ""
                    autocomplete.suggestions = []
                }
                .ignoresSafeArea(.keyboard)
        }
        .ignoresSafeArea(.keyboard)
        .preferredColorScheme(.dark)
    }
}

private extension WeatherView {
    var content: some View {
        ZStack {
            if weatherViewModel.stateApp == .empty {}
            else if weatherViewModel.stateApp == .loading {
                ProgressView()
            } else if weatherViewModel.stateApp == .error {
                VStack {
                    Spacer()
                    ErrorView(weatherVM: weatherViewModel)
                        .padding(.vertical, UIScreen.main.bounds.height * 0.329)
                    Spacer()
                }
            } else if weatherViewModel.stateApp == .loadData || weatherViewModel.stateApp == .loadDataAndImage {
                scrollView
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
            .padding(.vertical, UIScreen.main.bounds.height * 0.0)
            .padding(.bottom, 40)
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
        .padding(.vertical, 20)
    }
    }
    var statisticsCard: some View {
        VStack(spacing: 0) {
            weatherInfo
            textLabel
            getLocationButton
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .backgroundBlur(radius: 6, opaque: true)
        .background(Color.darkPurple.opacity(0.2))
        .cornerRadius(30)
    }
    var weatherData: some View {
        // MMain Weather Data
        ZStack {
            VStack(spacing: 0) {
                cityCard
                statisticsCard
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: searchedText) { _ in
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
        .padding(.vertical, UIScreen.main.bounds.height * 0.04)
        .padding(.horizontal, 20)
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
        WeatherView().preferredColorScheme(.dark)
    }
}
