//
//  WeatherView.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 29.06.2023.
//

import Foundation
import SwiftUI
import Combine

struct WeatherView: View {
    @StateObject var weatherVM = WeatherViewModel()
    @State var animationOpacity: Double = 0.0
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle().fill(Color.lightPurple.gradient)
                    .ignoresSafeArea()
                background
                ScrollView {
                    SearchText(weatherVM: weatherVM)
                        .padding(.vertical, UIScreen.main.bounds.height * 0.01)
                    if weatherVM.stateApp == .empty {

                    } else if weatherVM.stateApp == .loading {
                        LoadingView()
                            .padding(.vertical, UIScreen.main.bounds.height * 0.329)
                    } else if weatherVM.stateApp == .error {
                        VStack {
                            Spacer()
                            ErrorView(weatherVM: weatherVM)
                                .padding(.vertical, UIScreen.main.bounds.height * 0.329)
                            Spacer()
                        }
                    } else if weatherVM.stateApp == .loadData || weatherVM.stateApp == .loadDataAndImage {
                        content
                    }
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
                }
                .alert(item: $weatherVM.alertItem) { alertItem in
                    Alert(title: alertItem.title,
                          message: alertItem.message,
                          dismissButton: alertItem.dismissButton)
                }
                .padding(.vertical, UIScreen.main.bounds.height * 0.035)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.immediately)
            }
            .ignoresSafeArea(.keyboard)
            .preferredColorScheme(.dark)
        }
        .onAppear {
            // weatherVM.getLocation()
            weatherVM.getData(using: "London")
        }
    }
    var searchField: some View {
        SearchText(weatherVM: weatherVM)
    }
    @ViewBuilder
    var background: some View {

        ZStack {
            Rectangle().fill(Color.darkPurple.gradient.opacity(0.8))
            Rectangle().fill(Color.lightPurple.gradient.blendMode(.lighten).opacity(0.4))
            if weatherVM.stateApp == .loadDataAndImage {
                ImageRemote( animationOpacity: $animationOpacity, imageUrl: weatherVM.urlImg)
                    .scaledToFill()
                Rectangle().fill(Color.black.opacity(0.3).blendMode(.multiply))
            }
        }
        .ignoresSafeArea()
    }
}

private extension WeatherView {
    var content: some View {
        // MMain Weather Data
        VStack(spacing: 20) {
            Spacer()
            VStack {
                Text(weatherVM.weatherData.cityName)
                    .foregroundColor(.white)
                    .font(.system(size: 40, weight: .regular))
                    .multilineTextAlignment(.center)
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

            }
            .padding(.vertical, UIScreen.main.bounds.height * 0.03)
            .frame(width: 320)
            .backgroundBlur(radius: 20, opaque: true)
            .background(Color.darkPurple.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 40))
            .padding(.vertical, UIScreen.main.bounds.height * 0.03)

            weatherInfo
                .padding(.vertical, UIScreen.main.bounds.height * 0.04)
                .padding(.horizontal, 60)
            Text(weatherVM.weatherData.description)
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .thin))
                .padding(.vertical,  UIScreen.main.bounds.height * 0.0)
        }
        .background(

            Rectangle()
                .fill(.black.opacity(0.2))
                .background(Color.lightPurple.gradient.opacity(0.2))
                .backgroundBlur(radius: 10, opaque: true)
                .clipShape(RoundedRectangle(cornerRadius: 50))
                .frame(width: UIScreen.main.bounds.width, height: 800)
                .offset(y: 470)
        )
        // .opacity(animationOpacity)
        // .animation(.easeIn(duration: 2), value: animationOpacity)
        .onAppear {
            animationOpacity = 100.0
        }
        .onDisappear {
            animationOpacity = 0.0
        }
    }
    private var weatherInfo: some View {
        HStack(spacing: 10) {
            RoundIcon(imageName: "thermometer.medium", textInput: weatherVM.weatherData.feelsLike,
                      textTitle: "Feels like")
            RoundIcon(imageName: "humidity", textInput: weatherVM.weatherData.humidity, textTitle: "Humidity")
            RoundIcon(imageName: "gauge.medium", textInput: weatherVM.weatherData.pressure, textTitle: "Pressure")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherView().preferredColorScheme(.dark)
    }
}
