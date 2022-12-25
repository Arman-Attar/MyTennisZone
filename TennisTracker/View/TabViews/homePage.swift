//
//  homePage.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-09.
//

import SwiftUI

struct homePage: View {
    let viewList = [AnyView(createLeague()), AnyView(joinLeagueView()), AnyView(createTournament())]
    let pictureList = ["c_league", "j_league", "c_tourny"]
    let captionList = ["Create a League", "Join a League", "Create a Tournament"]
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false){
                VStack{
                    ForEach(0..<3) {index in
                        HomeOptionsView(bannerImage: pictureList[index], title: captionList[index], destinationView: viewList[index])
                    }
                }
            }.navigationTitle("Home")
        }
    }
}

struct homePage_Previews: PreviewProvider {
    static var previews: some View {
        homePage()
    }
}

