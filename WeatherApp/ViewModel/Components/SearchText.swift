//
//  SearchText.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 10.07.2023.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
struct SearchText: View {
    @State private var searchedText: String = ""
    @State private var isImageLoading = false
    @ObservedObject var weatherVM: WeatherViewModel
    var body: some View {
        HStack(spacing: 2) {

            Image(systemName: "magnifyingglass")
                .foregroundColor(.white)
                .padding(EdgeInsets.init(top: 0, leading: 0, bottom: 0, trailing: 10))
                .onTapGesture {
                    weatherVM.getData(using: searchedText)
                    searchedText = ""
                }
                .padding()
            TextField("Search", text: $searchedText)
                .onSubmit {
                    weatherVM.getData(using: searchedText)
                    searchedText = ""
                }
                .accentColor(.white)

        }
        .onTapGesture {
            self.hideKeyboard()
        }

        .frame(width: 320, height: 25)
        //.padding(.horizontal, 9)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 35)
                .fill(Color.darkPurple.opacity(0.5))
                .backgroundBlur(radius: 25, opaque: true)
                .clipShape(RoundedRectangle(cornerRadius: 35)))
    }
}

struct SearchText_Previews: PreviewProvider {
    static var previews: some View {
        SearchText(weatherVM: WeatherViewModel())
    }
}
