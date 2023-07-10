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
        HStack(spacing: 2) {

            //Spacer()
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white)
                .padding(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 10))
                .onTapGesture {
                    weatherVM.getData(using: searchedText)
                    searchedText = ""
                }
            TextField("Search", text: $searchedText)
                .onSubmit {
                    weatherVM.getData(using: searchedText)
                    searchedText = ""
                }
                .accentColor(.white)


        }
        //        TextField("Search", text: $searchedText)
        //            .onSubmit {
        //                weatherVM.getData(using: searchedText)
        //                searchedText = ""
        //            }
        //            .overlay(
        //                HStack {
        //                    Spacer()
        //                    Image(systemName: "magnifyingglass")
        //                        .foregroundColor(.gray)
        //                        .padding(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 10))
        //                        .onTapGesture {
        //                            weatherVM.getData(using: searchedText)
        //                            searchedText = ""
        //                        }
        //                }
        //            )
        .onTapGesture {
            self.hideKeyboard()
        }
        //.foregroundColor(.black)
        .padding(.horizontal, 9)
        .padding(.vertical, 7)
        //.tintColor(Color.white)

         .frame(width: 360, height: 38, alignment: .leading)

        .background(
            RoundedRectangle(cornerRadius: 35)
                .backgroundBlur(radius: 25, opaque: true)
               // .fill(Color.black.opacity(0.5))
                .foregroundColor(Color.darkPurple.opacity(0.8))
            //.foregroundColor(Color.black.opacity(0.5))


            // .background(Color.indigo.opacity(1))
        )
        .innerShadow(shape: RoundedRectangle(cornerRadius: 35), color: .gray.gradient, lineWidth: 1, blur: 0, blendMode: .overlay, opacity: 1)

        //.textFieldStyle(.roundedBorder)

    }
}

struct ImageLoader: View {
    @State private var imageOpacity = 0.0
    @Binding var animationOpacity: Double
    let imageUrl: String
    var body: some View {
        AsyncImage(url: URL(string: imageUrl)) { phase in
            if let image = phase.image {
                ZStack {
                    image.resizable()
                        .onAppear {
                            imageOpacity = 100.0
                            animationOpacity = 100.0
                        }
                        .onDisappear {
                            imageOpacity = 0.0
                            animationOpacity = 0.0
                        }
                        .opacity(imageOpacity)
                        .animation( .easeIn(duration: 2), value: imageOpacity)
                }
            } else if phase.error != nil {
                Text("No Image")

            } else {
                //                VStack {
                //                    ProgressView()
                //                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                //                        .scaleEffect(3)
                //                }
            }
        }
    }
}
struct ContentView: View {
    @StateObject var weatherVM = WeatherViewModel()
    // var weatherVM = WeatherViewModel()
    @StateObject var locationDataManager = LocationDataManager()
    @State private var isAlertShown: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var isDataShowing = false
    @State var animationOpacity: Double = 0.0
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

                            Spacer()
                            if weatherVM.errorMessage == nil && !weatherVM.isLoading && !weatherVM.isLoadingImg && weatherVM.urlWeather.isEmpty {

                                Spacer()
                            } else if( weatherVM.isLoading || weatherVM.isLoadingImg) && weatherVM.errorMessage == nil {
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
                                                .frame(width: 350)
                                            Text("Francie")
                                                .foregroundColor(.white)
                                                .font(.system(size: 20, weight: .thin))
                                                .frame(width: 315)
                                            HStack {
                                                Image(systemName: weatherVM.iconName)
                                                    .renderingMode(.original)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 80, height: 80)
                                                    .padding()
                                                Text(weatherVM.temp)
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 70, weight: .thin))
                                                    .padding()

                                            }
                                            Text("Cloudy")
                                                .foregroundColor(.white)
                                                .font(.system(size: 20, weight: .thin))

                                        }
                                        .padding(.vertical, 30)
                                        .backgroundBlur(radius: 20, opaque: true)
                                        .background(Color.darkPurple.opacity(0.5))

                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .innerShadow(shape: RoundedRectangle(cornerRadius: 20), color: .gray.gradient, lineWidth: 1, blur: 0.0, blendMode: .overlay, opacity: 1)
                                       // .padding()
                                        Spacer()
                                        Spacer()
                                        HStack(spacing: 30){
                                            HStack{



                                                VStack(spacing: 10){
                                                    Image(systemName: "humidity.fill")
                                                    Text("24%")
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 20, weight: .thin))
                                                }
                                                .padding(20)
                                                .backgroundBlur(radius: 45, opaque: true)
                                                //.background(Color.indigo.opacity(0.2))
                                                .background(Color.darkPurple.opacity(0.7))

                                                .clipShape(Circle())
                                                .innerShadow(shape: Circle(), color: .gray.gradient, lineWidth: 1, blur: 0.0, blendMode: .overlay, opacity: 1)

                                            }
                                            HStack {



                                                VStack(spacing: 10){
                                                    Image(systemName: "humidity.fill")
                                                    Text("24%")
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 20, weight: .thin))
                                                }
                                                .padding(20)
                                                .backgroundBlur(radius: 45, opaque: false)

                                                .background(Color.darkPurple.opacity(0.7))

                                                .clipShape(Circle())
                                                .innerShadow(shape: Circle(), color: .gray.gradient, lineWidth: 1, blur: 0.0, blendMode: .overlay, opacity: 1)

                                            }
                                            HStack {



                                                VStack(spacing: 10){
                                                    Image(systemName: "humidity.fill")
                                                    Text("24%")
                                                        .foregroundColor(.white)
                                                        .font(.system(size: 20, weight: .thin))
                                                }
                                                .padding(20)
                                                .backgroundBlur(radius: 45, opaque: false)
                                                .background(Color.darkPurple.opacity(0.7))

                                                .clipShape(Circle())
                                                .innerShadow(shape: Circle(), color: .gray.gradient, lineWidth: 1, blur: 0.0, blendMode: .overlay, opacity: 1)

                                            }
                                        }
                                        Spacer()
                                        HStack{
                                            Group{
                                                Text("Feels like:")
                                                Text("29°")
                                            }
                                            .font(.system(size: 20, weight: .thin))

                                        }


                                        Spacer()



                                        /* if weatherVM.errorMessageImage == nil {
                                         Spacer()
                                         ImageLoader(animationOpacity: $animationOpacity, imageUrl: weatherVM.urlImg)
                                         .scaledToFill()
                                         .frame(width: 150, height: 150, alignment: .center)
                                         .clipped()
                                         .clipShape(Circle())
                                         .padding()

                                         Spacer()

                                         } */
                                    }
                                } .opacity( animationOpacity)
                                    .animation( .easeIn(duration: 2), value: animationOpacity)
                                // .animation(.default, value: weatherVM.isLoadingImg)

                            }

                            Button {
                                print("get weather")
                                switch locationDataManager.locationManager.authorizationStatus {
                                case .authorizedWhenInUse:  // Location services are available.
                                    if let location = locationDataManager.locationManager.location?.coordinate {
                                        let locationCL = CLLocation(latitude: location.latitude, longitude: location.longitude)
                                        locationCL.fetchCityAndCountry { city, country, error in
                                            guard let city = city, let country = country, error == nil else { return }
                                            print("\(city), \(country)")  // Rio de Janeiro, Brazil
                                            weatherVM.getData(using: city, coordinats: location)
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
                        .backgroundBlur(radius: 25, opaque: true)

                        .background(Color.darkPurple.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 40))
                        .innerShadow(shape: RoundedRectangle(cornerRadius: 40), color: .gray.gradient, lineWidth: 1, blur: 0, blendMode: .overlay, opacity: 1)
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
        .onAppear{
            weatherVM.getData(using: "Viena")
        }

    }

    var searchField: some View {
        SearchText(weatherVM: weatherVM)
    }
    @ViewBuilder
    var background: some View {
        if !weatherVM.urlImg.isEmpty && !weatherVM.cityName.isEmpty && weatherVM.errorMessage == nil {
            GeometryReader { geo in
                ZStack {
                    Rectangle().overlay( ImageLoader( animationOpacity: $animationOpacity, imageUrl: weatherVM.urlImg)
                        .scaledToFill()
                        .ignoresSafeArea()
                        .clipped()
                        .blur(radius: 0)
                                         //.brightness(-0.02)
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
                    VStack{
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
