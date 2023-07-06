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
    var body: some View {

        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    ContainerRelativeShape().fill(.blue.gradient).ignoresSafeArea()

                    if weatherVM.isLoading || weatherVM.isLoadingImg {
                        LoadingView()
                    } else if weatherVM.errorMessage != nil {
                        VStack {
                            searchField
                                .padding()
                            ErrorView(weatherVM: weatherVM)
                            Spacer()
                        }

                    } else {

                        ZStack {
                            if weatherVM.errorMessageImage == nil &&  !weatherVM.urlImg.isEmpty {

                                ImageLoader( imageUrl: weatherVM.urlImg)
                                    .scaledToFill()
                                    .ignoresSafeArea()
                                    .blur(radius: 5)
                                    .frame(width: geometry.size.width * 1.3, height: geometry.size.height * 1.3)
                                    .brightness(-0.04)
                                ContainerRelativeShape()
                                    .fill(.black)
                                    .ignoresSafeArea()
                                    .opacity(0.3)
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        VStack {

                            SearchText( weatherVM: weatherVM)
                            if !weatherVM.urlImg.isEmpty {
                                ZStack {

                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(.ultraThinMaterial.opacity(0.6))
                                        .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.5)

                                    VStack {
                                        Text(weatherVM.cityName)
                                            .foregroundColor(.white)
                                            .font(.largeTitle)
                                        Image(systemName: weatherVM.iconName)
                                            .renderingMode(.original)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 120, height: 120)
                                        Text(weatherVM.temp)
                                            .foregroundColor(.white)
                                            .font(.system(size: 90, weight: .thin))
                                    }
                                }

                                if weatherVM.errorMessageImage == nil {

                                    ImageLoader(imageUrl: weatherVM.urlImg)
                                        .scaledToFill()
                                        .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                                        .clipShape(Circle())
                                    // .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)

                                }
                            }
                            Spacer()

                        }
                        .padding()
                    }
                } // .ignoresSafeArea(.keyboard)

                .frame(width: geometry.size.width, height: geometry.size.height)

            }
            .ignoresSafeArea(.keyboard)
            .animation(.default, value: weatherVM.isLoadingImg)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
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

                .frame(width: 250, height: 50)

                .background(Capsule()
                    .stroke(.white, lineWidth: 1))
                .foregroundColor(.white)

                }
            }
        }

    }

    var searchField: some View {
        SearchText(weatherVM: weatherVM)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
