//
//  ImageLoader.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 10.07.2023.
//

import SwiftUI

struct ImageLoader: View {
    @State private var imageOpacity = 0.0
    @Binding var animationOpacity: Double
    let imageUrl: String
    init( animationOpacity: Binding<Double> = .constant(100.0), imageUrl: String) {
        _animationOpacity = animationOpacity
        self.imageUrl = imageUrl
    }
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
                Text("Async Image loades HANDLE ELSE STATE!!!!!111")
            }
        }
    }
}

struct ImageLoader_Previews: PreviewProvider {
    static var previews: some View {
        ImageLoader(imageUrl: "")
    }
}
