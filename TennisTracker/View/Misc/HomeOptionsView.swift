//
//  HomeOptionsView.swift
//  MyTennisZone
//
//  Created by Arman Zadeh-Attar on 2022-12-24.
//

import SwiftUI

struct HomeOptionsView: View {
    let bannerImage: String
    let title: String
    let destinationView: AnyView
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(bannerImage)
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.size.width - 20, height: UIScreen.main.bounds.size.height/5)
                .cornerRadius(25)
                .shadow(radius: 10)
                .blur(radius: 1, opaque: false)
            
            HStack{
                Text(title)
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 9)
                    .padding()
            }
            NavigationLink(destination: destinationView){
                RoundedRectangle(cornerRadius: 25)
                    .frame(width: UIScreen.main.bounds.size.width - 20, height: UIScreen.main.bounds.size.height/5)
                    .opacity(0.0)
            }
        }.frame(width: UIScreen.main.bounds.size.width - 20, height: UIScreen.main.bounds.size.height/5)
            .padding(.vertical)
    }
}

struct HomeOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        HomeOptionsView(bannerImage: "c_league", title: "Create a League", destinationView: AnyView(createTournament()))
    }
}
