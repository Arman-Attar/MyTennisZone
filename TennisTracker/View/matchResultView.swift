//
//  addSetsView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-25.
//

import SwiftUI
import SDWebImageSwiftUI

struct matchResultView: View {
    @ObservedObject var leagueVm = LeagueViewModel()
    var body: some View {
            Form{
                Text("Match Result")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                vsSection
                HStack{
                    Spacer()
                    Text("Set Scores")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    Spacer()
                }
                ScrollView {
                    ForEach(leagueVm.currentSets, id: \.setId) { set in
                        HStack{
                            Spacer()
                            Text("\(set.player1Points)").font(.system(size: 50, weight: .black))
                            Text("-").font(.system(size: 50, weight: .black))
                            Text("\(set.player2Points)").font(.system(size: 50, weight: .black))
                            Spacer()
                        }
                    }
                }
            }
    }
}

struct addSetsView_Previews: PreviewProvider {
    static var previews: some View {
        matchResultView()
    }
}

extension matchResultView{
    private var vsSection: some View {
        HStack{
            VStack
            {
                WebImage(url: URL(string: leagueVm.currentMatch!.player1Pic))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(radius: 20)
                    .padding(.horizontal)
                
                Text(leagueVm.currentMatch!.player1DisplayName)
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(width: 100, height: 50)
            }
            
            Text("VS")
                .font(.system(size: 20, weight: .bold))
                .offset(y: -25)
            
            VStack
            {
               WebImage(url: URL(string: leagueVm.currentMatch!.player2Pic))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .shadow(radius: 20)
                .padding(.horizontal)
            
            Text(leagueVm.currentMatch!.player2DisplayName)
                .font(.system(size: 15, weight: .bold))
                .multilineTextAlignment(.leading)
                .frame(width: 100, height: 50)
            }
            
        }.padding(.vertical)
    }
}
