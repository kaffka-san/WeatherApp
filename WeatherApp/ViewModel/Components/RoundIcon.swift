//
//  RoundIcon.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 10.07.2023.
//

import SwiftUI

struct RoundIcon: View {
    let imageName: String
    let textInput: String
    let textTitle: String
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: imageName)
            Text(textTitle)
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            Text(textInput)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .thin))
        }
        .frame(width: 90, height: 90)
         .padding(10)
        .backgroundBlur(radius: 15, opaque: true)
        .background(Color.lightPurple.gradient.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct RoundIcon_Previews: PreviewProvider {
    static var previews: some View {
        RoundIcon(imageName: "plus", textInput: "1080 HPa", textTitle: "Feels like")
    }
}
