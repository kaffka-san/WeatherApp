//
//  ContentView.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 29.06.2023.
//

import Foundation
import SwiftUI
import Combine

struct ContentView: View {
    @StateObject var weatherVM = WeatherViewModel()
    @State private var isDataShowing = false
    @State var animationOpacity: Double = 0
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ZStack {
                    Rectangle()
                        .overlay(background)
                        .ignoresSafeArea()
                    ScrollView {
                        VStack {
                            SearchText(weatherVM: weatherVM)
                            if weatherVM.stateApp == .empty {

                                Spacer()
                            } else if weatherVM.stateApp == .loading {
                                Spacer()
                                LoadingView()
                                Spacer()
                            } else if weatherVM.stateApp == .error {
                                VStack {
                                    Spacer()
                                    ErrorView(weatherVM: weatherVM)
                                    Spacer()
                                }
                            } else if weatherVM.stateApp == .loadDataAndImage {
                                // MMain Weather Data
                                VStack(spacing: 20) {
                                    Spacer()
                                    VStack {
                                        Text(weatherVM.weatherData.cityName)
                                            .foregroundColor(.white)
                                            .font(.largeTitle)
                                            .multilineTextAlignment(.center)
                                        Text(weatherVM.weatherData.countryName)
                                            .foregroundColor(.white)
                                            .font(.system(size: 20, weight: .thin))
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
                                    .padding(.vertical, 30)
                                    .padding(.horizontal, 30)
                                    .backgroundBlur(radius: 20, opaque: true)
                                    .background(Color.darkPurple.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 40))
                                    Spacer()
                                    Spacer()
                                    Spacer()
                                    HStack(spacing: 0) {
                                        RoundIcon(imageName: "thermometer.medium", textInput: weatherVM.weatherData.feelsLie)
                                        RoundIcon(imageName: "humidity", textInput: weatherVM.weatherData.humidity)
                                        RoundIcon(imageName: "gauge.medium", textInput: weatherVM.weatherData.preassure)
                                    }

                                   // Spacer()

                                    Text(weatherVM.weatherData.description)
                                        .foregroundColor(.white)
                                        .font(.system(size: 20, weight: .thin))
                                        .font(.system(size: 20, weight: .thin))

                                    Spacer()

                                }
                                .opacity(animationOpacity)
                                .animation(.easeIn(duration: 2), value: animationOpacity)
                            }
                            Button {
                                weatherVM.getLocation()
                            }
                        label: {
                            HStack {
                                Text("Current location")
                                Image(systemName: "location.circle.fill")
                            }
                        }
                        .alert(item: $weatherVM.alertItem) { alertItem in
                            Alert(title: alertItem.title,
                                  message: alertItem.message,
                                  dismissButton: alertItem.dismissButton)
                        }
                        .frame(width: 250, height: 50)
                        .backgroundBlur(radius: 25, opaque: true)
                        .background(Color.lightPurple.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                        .foregroundColor(.white)

                        }

                        .frame(height: geo.size.height * 0.95)
                        .padding()
                    }
                    .scrollDismissesKeyboard(.immediately)
                }
            }
            .ignoresSafeArea(.keyboard)
            .preferredColorScheme(.dark)

        }
        .onAppear {
            weatherVM.getData(using: "Viena")
        }
    }
    var searchField: some View {
        SearchText(weatherVM: weatherVM)
    }
    @ViewBuilder
    var background: some View {
        if weatherVM.stateApp == .loadDataAndImage {
            GeometryReader { geo in
                ZStack {
                    Rectangle().overlay( ImageLoader( animationOpacity: $animationOpacity, imageUrl: weatherVM.urlImg)
                        .scaledToFill()
                        .ignoresSafeArea()
                        .clipped()
                        .blur(radius: 0)
                                         // .brightness(-0.02)
                    )
                    // .contrast(1.2)
                    .allowsHitTesting(false)
                    Rectangle().fill(.black)
                        .opacity(0.1)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                    Rectangle().fill(.indigo.blendMode(.multiply))
                        .opacity(0.3)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(.black.opacity(0.2))
                            .background(Color.indigo.opacity(0.1))
                            .backgroundBlur(radius: 8, opaque: true)
                            .frame(width: 310, height: geo.size.height * 0.4)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                }
                .scaleEffect(1.3)
            }

        } else {
            Rectangle()
                .fill(.indigo.gradient)
                .ignoresSafeArea()
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.dark)
    }
}
