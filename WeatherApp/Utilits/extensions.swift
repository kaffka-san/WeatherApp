//
//  extensions.swift
//  WeatherApp
//
//  Created by Anastasia Lenina on 07.07.2023.
//

import SwiftUI

extension View {
    func backgroundBlur(radius: CGFloat = 3, opaque: Bool = false) -> some View {
        self
            .background(
                Blur(radius: radius, opaque: opaque)
            )
    }
}
extension View {
    func innerShadow <S: Shape, SS: ShapeStyle>(shape: S,
                                                color: SS,
                                                lineWidth: CGFloat = 1,
                                                blur: CGFloat = 5,
                                                blendMode: BlendMode = .normal,
                                                opacity: Double = 1) -> some View {
        self
//            .overlay {
//                shape
//                    .stroke(color, lineWidth: lineWidth)
//                    .blendMode(blendMode)
//                    .offset(y: 1)
//                    .blur(radius: blur)
//                    .mask { shape }
//                    .opacity(opacity)
//            }
    }
}

extension Color {
    static let darkPurple = Color("DarkPurple")
    static let lightPurple = Color("LightPurple")
}
