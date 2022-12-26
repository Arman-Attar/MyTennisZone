//
//  LeagueSearchedCell.swift
//  MyTennisZone
//
//  Created by Arman Zadeh-Attar on 2022-12-25.
//

import SwiftUI
import SDWebImageSwiftUI

struct LeagueSearchedCell: View {
    let league: League
    var body: some View {
        HStack{
            bannerSection
            leagueNameSection
            Spacer()
            playerCountSection
        }.padding(.horizontal)
    }
}

struct LeagueSearchedCell_Previews: PreviewProvider {
    static var previews: some View {
        LeagueSearchedCell(league: League(name: "Test League", playerId: ["1", "2", "3"], players: [Player(uid: "", profilePicUrl: "", displayName: "King of Pavement", points: 0, wins: 0, losses: 0  )], matches: [], bannerURL: "", admin: "arman")).previewLayout(.sizeThatFits).padding()
    }
}

extension LeagueSearchedCell {
    private var bannerSection: some View {
        VStack {
            if league.bannerURL != "" {
                WebImage(url: URL(string: league.bannerURL))
                    .userImageModifier(width: 60, height: 60)
            } else {
                Image("league")
                    .userImageModifier(width: 60, height: 60)
            }
        }
    }
    
    private var leagueNameSection: some View {
        VStack {
            HStack {
                Text(league.name.capitalized)
                    .font(.headline).fontWeight(.bold).foregroundColor(.black).lineLimit(1).minimumScaleFactor(0.5)
                Spacer()
            }
            HStack {
                Text("Admin: \(league.players[0].displayName)").font(.subheadline).fontWeight(.medium).foregroundColor(.black).lineLimit(1).minimumScaleFactor(0.5)
                Spacer()
            }
        }.padding(.horizontal)
    }
    
    private var playerCountSection: some View {
        HStack {
            Image(systemName: "person.fill").font(.title2).foregroundColor(.black)
            Text("\(league.playerId.count)").font(.title2).fontWeight(.bold).foregroundColor(.black)
        }.padding(.vertical)
    }
}
