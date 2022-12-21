//
//  UserImageModifier.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-21.
//

import Foundation
import SwiftUI
import SDWebImage
import SDWebImageSwiftUI


extension Image {
    func userImageModifier(width: Double, height: Double) -> some View {
        self
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: width, height: height)
        .clipShape(Circle())
        .shadow(color: .gray, radius: 3, y: 8)
    }
}

extension WebImage {
    func userImageModifier(width: Double, height: Double) -> some View {
        self
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: width, height: height)
        .clipShape(Circle())
        .shadow(color: .gray, radius: 3, y: 8)
    }
}
