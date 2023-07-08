//
//  Loading.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 02.07.2023.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
//            Rectangle()
//                .fill(.cyan)
//                .ignoresSafeArea()
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(3)
            }

        }

    }
}

struct Loading_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
