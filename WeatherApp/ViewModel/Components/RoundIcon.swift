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
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: imageName)
            Text(textInput)
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .thin))
        }
        .frame(width: 80)
        .padding()
        .backgroundBlur(radius: 45, opaque: true)
        .background(Color.lightPurple.opacity(0.8))
        .clipShape(Circle())
    }
}

struct RoundIcon_Previews: PreviewProvider {
    static var previews: some View {
        RoundIcon(imageName: "plus", textInput: "1080.12")
    }
}
