//
//  ProfileTabOptionModifier.swift
//  MyTennisZone
//
//  Created by Arman Zadeh-Attar on 2022-12-24.
//

import Foundation
import SwiftUI

struct ProfileTabOptionImageModifier: ViewModifier {
    let textColor: Color
    func body(content: Content) -> some View {
        content
            .font(.title)
            .foregroundColor(textColor)
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
    }
}

extension View {
    func profileTabButtonImageModifier(textColor: Color) -> some View {
        modifier(ProfileTabOptionImageModifier(textColor: textColor))
    }
}
