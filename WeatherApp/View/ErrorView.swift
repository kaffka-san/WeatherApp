//
//  ErrorVIew.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 02.07.2023.
//

import SwiftUI

struct ErrorView: View {
   @State private var errorMessage: String?

    init(errorMessage: String?) {
        self.errorMessage = errorMessage
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.darkPurple.gradient)
                .ignoresSafeArea()
            VStack {
                Spacer()
                Text(String(errorMessage ?? "Unexpected error has occur"))
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding(.vertical, 50)
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
        ErrorView( errorMessage: "Error parse data")
    }
}
