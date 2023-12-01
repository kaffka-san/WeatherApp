//
//  ErrorView.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 02.07.2023.
//

import SwiftUI

struct ErrorView: View {
   @State private var errorMessage: String

    init(errorMessage: String) {
        self.errorMessage = errorMessage
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.darkPurple.gradient)
                .ignoresSafeArea()
            VStack {
                Spacer()
                Text(errorMessage)
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.vertical, 50)
                    .padding(.horizontal, 40)

                Image(systemName: "sun.max.trianglebadge.exclamationmark")
                    .resizable()
                    .foregroundColor(.white.opacity(0.2))
                    .scaledToFit()
                    .frame(width: 450, height: 450)
                    .offset(x: 70, y: 0)
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        // swiftlint:disable:next line_length
        ErrorView( errorMessage: "We're sorry, but we couldn't find the city you're looking for. Please check your spelling and try again.")
    }
}
