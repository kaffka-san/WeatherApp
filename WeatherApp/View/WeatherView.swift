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
    @StateObject var weatherVM = WeatherViewModel()
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
                    weatherVM.getData(using: "London")
                }
                .searchable(text: $searchedText, placement: .navigationBarDrawer(displayMode: .always), suggestions: {
                    ForEach(autocomplete.suggestions, id: \.self) { suggestion in
                        Text(suggestion)
                            .searchCompletion(suggestion)
                    }
                }
                )
                .onSubmit(of: .search) { // 1
                    print("submit")
                    weatherVM.getData(using: searchedText)
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
            if weatherVM.stateApp == .empty {
            }
            else if weatherVM.stateApp == .loading {
                ProgressView()
            }
            else if weatherVM.stateApp == .error {
                VStack {
                    Spacer()
                    ErrorView(weatherVM: weatherVM)
                        .padding(.vertical, UIScreen.main.bounds.height * 0.329)
                    Spacer()
                }
            } else if weatherVM.stateApp == .loadData || weatherVM.stateApp == .loadDataAndImage {
                backgroundImage
                scrollView
            }
        }
    }

    var scrollView: some View {
        ScrollView {
            weatherData
                .scrollIndicators(.hidden)
        }
        .ignoresSafeArea(.keyboard)
        .edgesIgnoringSafeArea(.horizontal)
        .alert(item: $weatherVM.alertItem) { alertItem in
            Alert(title: alertItem.title,
                  message: alertItem.message,
                  dismissButton: alertItem.dismissButton)
        }
    }
    var backgroundImage: some View {
        ZStack {
            Rectangle().fill(Color.darkPurple.gradient.opacity(0.8))
            Rectangle().fill(Color.lightPurple.gradient.blendMode(.lighten).opacity(0.4))
            if weatherVM.stateApp == .loadDataAndImage {
                ZStack {
                    AsyncImage(url: URL(string: weatherVM.urlImg)) { image in
                        image.image?
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width)
                            .transition(.opacity.animation(.easeInOut(duration: 0.6)))
                    }
                    Rectangle().fill(Color.black.opacity(0.3).blendMode(.multiply))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }

    var cityCard: some View {
        VStack {
            Text(weatherVM.weatherData.cityName)
                .foregroundColor(.white)
                .font(.system(size: 40, weight: .regular))
                .multilineTextAlignment(.center)
                .padding(.vertical, 5)
            Text(weatherVM.weatherData.countryName)
                .foregroundColor(.white)
                .font(.system(size: 25, weight: .thin))
                .multilineTextAlignment(.center)

            HStack {
                Image(systemName: weatherVM.weatherData.iconName)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding()
                Text(weatherVM.weatherData.temp)
                    .foregroundColor(.white)
                    .font(.system(size: 70, weight: .thin))
                    .padding()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, UIScreen.main.bounds.height * 0.03)
        .backgroundBlur(radius: 20, opaque: true)
        .background(Color.darkPurple.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 40))
        .padding(.horizontal, 36)
    }

    var textLabel: some View {
        Text(weatherVM.weatherData.description)
            .foregroundColor(.white)
            .font(.system(size: 20, weight: .thin))
            .padding(.vertical, UIScreen.main.bounds.height * 0.0)
    }

    var getLocationButton: some View {
        Button {
            weatherVM.getLocation()
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
                .padding(.bottom, 40)
            getLocationButton

        }
        .padding(.vertical, 20)
        .background {
            Color.black.opacity(0.2)
                .background(Color.lightPurple.gradient.opacity(0.2))
                .cornerRadius(30)

        }
    }
    var weatherData: some View {
        // MMain Weather Data
        ZStack {
            VStack(spacing: 0) {
                cityCard
                //.padding(.top, 30)
                    .padding(.bottom, 60)
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
            RectangleIcon(imageName: "thermometer.medium", textInput: weatherVM.weatherData.feelsLike,
                          textTitle: "Feels like")
            RectangleIcon(imageName: "humidity", textInput: weatherVM.weatherData.humidity, textTitle: "Humidity")
            RectangleIcon(imageName: "gauge.medium", textInput: weatherVM.weatherData.pressure, textTitle: "Pressure")
        }
        .padding(.vertical, UIScreen.main.bounds.height * 0.04)
        .padding(.horizontal, 20)
    }

    func configNavigationBar() {
        UINavigationBar.appearance().barTintColor = .clear
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
