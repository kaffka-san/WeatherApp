//
//  ImageLoader.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 10.07.2023.
//

import SwiftUI

final class ImageLoader: ObservableObject {
    @Published var image: Image?
    @Published var isLoadingImg = false
    func load(from urlString: String) {
        isLoadingImg = true
        NetworkManager.shared.downloadImage(fromUrlString: urlString) { uiImage in
            guard let uiImage else {
                self.isLoadingImg = false
                return

            }
            DispatchQueue.main.async {
                self.isLoadingImg = false
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
        ZStack {
            if imageLoader.isLoadingImg {
                Rectangle()
                    .fill(Color.lightPurple.gradient)
                    .ignoresSafeArea()
                 ProgressView()

            } else if !imageLoader.isLoadingImg {
                ImageRem(image: imageLoader.image)

            }
        }
        .onAppear {
            imageLoader.load(from: imageUrl)
            print("on appear")
        }

        // .opacity(animationOpacity)
         // .animation( .easeIn(duration: 2), value: animationOpacity)
    }
}

struct ImageLoader_Previews: PreviewProvider {
    static var previews: some View {
        ImageRemote(imageUrl: "https://api.unsplash.com/search/photos?client_id=gFleRQgTSJRjceXWzsxPJHnPXwiA-iec1UzHY_Mz9wE&query=san%20francisco&page=1")
    }
}
