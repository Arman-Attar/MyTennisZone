//
//  TournamentWinnerView.swift
//  MyTennisZone
//
//  Created by Arman Zadeh-Attar on 2022-12-24.
//

import SwiftUI
import SDWebImageSwiftUI

struct TournamentWinnerView: View {
    @ObservedObject var tournamentVm: TournamentViewModel
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false){
                VStack {
                    HStack{
                        Rectangle().frame(height: 1)
                        Text("Winner").font(.subheadline).fontWeight(.heavy).padding(.horizontal)
                        Rectangle().frame(height: 1)
                    }
                    VStack{
                        Spacer()
                        if tournamentVm.playerList.count > 1 {
                            Image("profile")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 130, height: 130)
                                .clipShape(Circle())
                                .shadow(radius: 20)
                            Text("To Be Determined").fontWeight(.heavy).padding()
                        }
                        else {
                            if tournamentVm.tournament?.players[0].profilePicUrl ?? "" != ""{
                                
                                WebImage(url: URL(string: tournamentVm.playerList[0].profilePicUrl))
                                    .userImageModifier(width: 150, height: 150)
                                
                            }
                            else {
                                Image("profile")
                                    .userImageModifier(width: 150, height: 150)
                            }
                            
                            Text("\(tournamentVm.tournament!.players[0].displayName)").fontWeight(.heavy).padding()
                        }
                        Spacer()
                    }.padding(.top)
                }
                Divider().padding(.horizontal)
                HStack{
                    VStack{
                        Text("\(tournamentVm.tournament!.numberOfPlayers)").font(.system(size: 70)).fontWeight(.black)
                        Text("PLAYERS ENTERED").font(.subheadline)
                    }
                    Divider().padding()
                    VStack{
                        Text("\(tournamentVm.playerList.count)").font(.system(size: 70)).fontWeight(.black)
                        Text("PLAYERS LEFT").font(.subheadline)
                    }
                }.padding()
            }.padding()
        }
    }
}

struct TournamentWinnerView_Previews: PreviewProvider {
    static var previews: some View {
        TournamentWinnerView(tournamentVm: TournamentViewModel())
    }
}
