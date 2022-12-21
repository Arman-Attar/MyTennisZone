//
//  TextFieldKeyboardModifier.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-20.
//

import Foundation
import SwiftUI

struct TextFieldKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .foregroundColor(.black)
    }
}

struct OnBoardingButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2)
            .padding()
            .foregroundColor(.black)
            .frame(maxWidth: UIScreen.main.bounds.size.width / 1.25, maxHeight: 20)
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 100)
                .stroke(Color.black, lineWidth: 0.8))
            .padding()
            .offset(y: 9)
    }
}

struct OnBoardingMessageModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body)
            .foregroundColor(Color.black)
            .multilineTextAlignment(.center)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(21)
            .padding()
    }
}

extension View {
    func KeyboardModifier() -> some View {
        modifier(TextFieldKeyboardModifier())
    }
    
    func ButtonModifier() -> some View {
        modifier(OnBoardingButtonModifier())
    }
    
    func MessageModifier() -> some View {
        modifier(OnBoardingMessageModifier())
    }
}
