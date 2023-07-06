//
//  ErrorVIew.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 02.07.2023.
//

import SwiftUI

struct ErrorView: View {
    @ObservedObject var weatherVM: WeatherViewModel
    var body: some View {
        Text(String(weatherVM.errorMessage ?? "some error"))
            .foregroundColor(.white)
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(weatherVM: WeatherViewModel())
    }
}
