//
//  StandingsView.swift
//  MyTennisZone
//
//  Created by Arman Zadeh-Attar on 2022-12-24.
//

import SwiftUI
import SDWebImageSwiftUI

struct StandingsView: View {
    let playerList: [Player]
    var body: some View {
        ScrollView{
            VStack{
                ForEach(Array(playerList.enumerated()), id: \.offset) { index, player in
                    VStack {
                        HStack {
                            Text("\(index + 1).")
                                .font(.headline)
                                .padding(.leading)
                            if player.profilePicUrl != "" {
                                WebImage(url: URL(string: player.profilePicUrl))
                                    .userImageModifier(width: 80, height: 80)
                                    .padding()
                            } else {
                                Image("profile")
                                    .userImageModifier(width: 80, height: 80)
                                    .padding()
                            }
                            Divider()
                            VStack {
                                Text(player.displayName)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.leading)
                                    .padding()
                                Divider()
                                VStack(alignment: .leading){
                                    HStack{
                                        VStack {
                                            Text("PL").padding(8).font(.system(size: 13, weight: .semibold))
                                            Text("\((player.wins) + (player.losses))").padding(8).font(.system(size: 11, weight: .semibold))
                                        }
                                        VStack {
                                            Text("W").padding(8).font(.system(size: 13, weight: .semibold))
                                            Text("\(player.wins)").padding(8).font(.system(size: 11, weight: .semibold))
                                        }
                                        VStack {
                                            Text("L").padding(8).font(.system(size: 13, weight: .semibold))
                                            
                                            Text("\(player.losses)").padding(8).font(.system(size: 11, weight: .semibold))
                                            
                                        }
                                        VStack {
                                            Text("PTS").padding(8).font(.system(size: 13, weight: .semibold))
                                            
                                            Text("\(player.points)").padding(8).font(.system(size: 11, weight: .semibold))
                                            
                                        }
                                    }.padding(.horizontal)
                                }
                            }
                            Spacer()
                        }
                        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height/6)
                        Divider().padding(.horizontal)
                    }
                }
            }
        }
    }
}

struct StandingsView_Previews: PreviewProvider {
    static var previews: some View {
        StandingsView(playerList: [])
    }
}
