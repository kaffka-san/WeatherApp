//
//  ContentView.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 29.06.2023.
//

import Foundation
import SwiftUI
import Combine
import CoreLocation
import CoreLocationUI
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct SearchText: View {
    @State private var searchedText: String = ""
    @State private var isImageLoading = false
    @ObservedObject var weatherVM: WeatherViewModel
    var body: some View {
        TextField("Search", text: $searchedText)
            .onSubmit {
                searchCity()
            }
        // .ignoresSafeArea(.keyboard)
            .overlay(
                HStack {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 10))
                        .onTapGesture {
                            searchCity()
                        }
                }
            )
            .onTapGesture {
                self.hideKeyboard()
            }
            .textFieldStyle(.roundedBorder)
    }
    @MainActor func searchCity() {
        weatherVM.createUrl(cityNameSearched: searchedText)
        weatherVM.createImgUrl(cityNameSearched: searchedText)
        weatherVM.fetchAsync()
        weatherVM.fetchAsyncImg()
        weatherVM.isLoading = true
        searchedText = ""
        weatherVM.urlImg = ""
    }
}

struct ImageLoader: View {
    @State private var imageOpacity = 0.0
    let imageUrl: String
    var body: some View {
        AsyncImage(url: URL(string: imageUrl)) { phase in
            if let image = phase.image {

                ZStack {
                    image.resizable()
                        .onAppear {
                            imageOpacity = 100.0
                        }
                        .onDisappear {
                            imageOpacity = 0.0
                        }
                        .opacity(imageOpacity)
                        .animation( .easeIn(duration: 2), value: imageOpacity)
                }
            } else if phase.error != nil {
                Text("No Image")

            } else {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(3)
                }
            }
        }
    }
}
struct ContentView: View {

    @StateObject var weatherVM = WeatherViewModel()
    @StateObject var locationDataManager = LocationDataManager()
    @State private var isAlertShown: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isDataShowing = false
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Rectangle()
                    .overlay(background)
                    .ignoresSafeArea()

                ScrollView {
                    VStack {
                        SearchText(weatherVM: weatherVM)

                        Spacer()
                        if weatherVM.errorMessage == nil && !weatherVM.isLoading && !weatherVM.isLoadingImg && weatherVM.urlWeather.isEmpty {

                            Spacer()
                        } else if weatherVM.isLoading || weatherVM.isLoadingImg {
                            Spacer()
                            LoadingView()
                            Spacer()
                        } else if weatherVM.errorMessage != nil {
                            VStack {
                                Spacer()
                                ErrorView(weatherVM: weatherVM)
                                Spacer()
                            }
                        } else {
                            VStack {
                                if !weatherVM.urlImg.isEmpty {
                                    Spacer()
                                    VStack {
                                        Text(weatherVM.cityName)
                                            .foregroundColor(.white)
                                            .font(.largeTitle)
                                            .frame(width: 300)
                                        Image(systemName: weatherVM.iconName)
                                            .renderingMode(.original)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80, height: 80)
                                        Text(weatherVM.temp)
                                            .foregroundColor(.white)
                                            .font(.system(size: 70, weight: .thin))
                                    }
                                    .padding(.vertical, 10)

                                    .background(
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(.ultraThinMaterial.opacity(0.7))
                                            RoundedRectangle(cornerRadius: 20)
                                                .fill(.black.opacity(0.3))
                                        }

                                    )
                                    .padding()
                                    if weatherVM.errorMessageImage == nil {
                                        Spacer()
                                        ImageLoader(imageUrl: weatherVM.urlImg)
                                            .scaledToFill()
                                            .frame(width: 150, height: 150, alignment: .center)
                                            .clipped()
                                            .clipShape(Circle())
                                            .padding()
                                        Spacer()

                                    }

                                }
                            }

                            .animation(.default, value: weatherVM.isLoadingImg)

                        }
                        // tuu
                        Button {
                            print("get weather")
                            switch locationDataManager.locationManager.authorizationStatus {
                            case .authorizedWhenInUse:  // Location services are available.
                                if let location = locationDataManager.locationManager.location?.coordinate {
                                    let locationCL = CLLocation(latitude: location.latitude, longitude: location.longitude)
                                    locationCL.fetchCityAndCountry { city, _, error in
                                        guard let city = city, error == nil else { return }
                                        print(city)  // Rio de Janeiro, Brazil
                                        weatherVM.createImgUrl(cityNameSearched: city)
                                        print("location is \(location)")
                                        weatherVM.getWeatherFromLocation(for: location)
                                        weatherVM.fetchAsyncImg()
                                        weatherVM.fetchAsync()
                                    }
                                }

                            case .restricted, .denied:  // Location services currently unavailable.
                                // Insert code here of what should happen when Location services are NOT authorized
                                alertTitle = "Eror"
                                alertMessage = ("Current location data was restricted or denied.")
                                isAlertShown = true
                            case .notDetermined:        // Authorization not determined yet.
                                Text("Finding your location...")
                                ProgressView()
                            default:
                                ProgressView()
                            }

                        }
                    label: {
                        HStack {
                            Text("Current location")
                            Image(systemName: "location.circle.fill")
                        }
                    }
                    .alert(isPresented: $isAlertShown, content: {
                        Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Got it!")))
                    })
                        // .contentShape(Rectangle())
                    .frame(width: 250, height: 50)

                    .background(Capsule()
                        .stroke(.white, lineWidth: 1))
                    .foregroundColor(.white)
                   // .padding()

                    }

                    .frame(height: geo.size.height * 0.95)
                    // .ignoresSafeArea(.keyboard)
                    .padding()
                }

            }
        } .ignoresSafeArea(.keyboard)

    }

    var searchField: some View {

        SearchText(weatherVM: weatherVM)
    }
    @ViewBuilder
    var background: some View {
        if !weatherVM.urlImg.isEmpty && !weatherVM.cityName.isEmpty && weatherVM.errorMessage == nil {
            ZStack {
                Rectangle().overlay( ImageLoader( imageUrl: weatherVM.urlImg)
                    .scaledToFill()
                    .ignoresSafeArea()

                    .clipped()

                    .blur(radius: 5)
                    .brightness(-0.02))
                .allowsHitTesting(false)
                Rectangle().fill(.black)
                    .opacity(0.2)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

            }

        } else {
            Rectangle()
                .fill(.blue.gradient)
                .ignoresSafeArea()

        }
    }

}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
