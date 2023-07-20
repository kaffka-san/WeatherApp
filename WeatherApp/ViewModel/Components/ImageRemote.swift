//
//  ImageLoader.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 10.07.2023.
//

import SwiftUI

final class ImageLoader: ObservableObject {
    @Published var image: Image?
    func load(from urlString: String) {
        NetworkManager.shared.downloadImage(fromUrlString: urlString) { uiImage in
            guard let uiImage else {return}
            DispatchQueue.main.async {
                self.image = Image(uiImage: uiImage)
                print("dispatch image on main thread")
            }
        }
    }
}
struct ImageRem: View {
    var image: Image?
    var body: some View {
        image?.resizable() ?? nil
    }
}
struct ImageRemote: View {
   // @State private var imageOpacity = 0.0
    @Binding var animationOpacity: Double
    @StateObject var imageLoader = ImageLoader()
    let imageUrl: String
    init( animationOpacity: Binding<Double> = .constant(100.0), imageUrl: String) {
        _animationOpacity = animationOpacity
        self.imageUrl = imageUrl
    }
    var body: some View {

        ImageRem(image: imageLoader.image)
            .onAppear {
                imageLoader.load(from: imageUrl)
                print("on appear")
            }
            .opacity(animationOpacity)
            .animation( .easeIn(duration: 2), value: animationOpacity)
    }
}

struct ImageLoader_Previews: PreviewProvider {
    static var previews: some View {
        ImageRemote(imageUrl: "")
    }
}
