//
//  CustomDivider.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-20.
//

import SwiftUI

struct CustomDivider: View {
    var body: some View {
        VStack{
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .padding(.horizontal)
                .foregroundColor(.black)
                .padding(.vertical)
        }
    }
}

struct CustomDivider_Previews: PreviewProvider {
    static var previews: some View {
        CustomDivider()
    }
}
