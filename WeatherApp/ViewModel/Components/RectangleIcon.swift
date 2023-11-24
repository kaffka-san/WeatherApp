//
//  RectangleIcon.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 10.07.2023.
//

import SwiftUI

struct RectangleIcon: View {
    let imageName: String
    let textInput: String
    let textTitle: String
    var body: some View {

        VStack(spacing: 15) {
            HStack {
                Image(systemName: imageName)
                    .imageScale(.small)
                Text(textTitle)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
            }
            Text(textInput)
                .foregroundColor(.white.opacity(0.8))
                .font(.system(size: 22, weight: .thin))
        }
        .frame(width: 93, height: 93)
        .padding(10)
        .backgroundBlur(radius: 15, opaque: true)
        .background(Color.lightPurple.gradient.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct RoundIcon_Previews: PreviewProvider {
    static var previews: some View {
        RectangleIcon(imageName: "plus", textInput: "1080 HPa", textTitle: "Feels like")
    }
}
