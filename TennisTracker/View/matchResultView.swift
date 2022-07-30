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
    @Environment(\.dismiss) var dismiss
    @State var settingTapped = false
    @State var confirmDeleteAlert = false
    @ObservedObject var userVm = UserViewModel()
    @ObservedObject var tournamentVm = TournamentViewModel()
    @State var isLeague = true
    var body: some View {
            VStack{
                    HStack{
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "arrow.left").font(.title3)
                            Text("Back").font(.title3)
                        }.padding()
                        Spacer()
                        if isLeague{
                        if leagueVm.league!.admin == userVm.user!.uid {
                        Button {
                            settingTapped.toggle()
                        } label: {
                            Image(systemName: "gear").font(.title3)
                        }.padding([.top, .horizontal])
                        }
                        } else {
                            if tournamentVm.tournament!.admin == userVm.user!.uid {
                            Button {
                                settingTapped.toggle()
                            } label: {
                                Image(systemName: "gear").font(.title3)
                            }.padding([.top, .horizontal])
                            }
                        }
                    }.padding()
                    
                    
                    HStack {
                        Text("Match Result")
                                    .font(.title)
                                    .fontWeight(.bold)
                                .padding(.horizontal)
                    }.padding(.bottom)
                            vsSection
                            HStack{
                                Spacer()
                                Text("Set Scores")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding()
                                Spacer()
                            }.padding(.bottom)
                            ScrollView {
                                ForEach(isLeague ? leagueVm.currentSets : tournamentVm.currentSets, id: \.setId) { set in
                                    HStack{
                                        Spacer()
                                        Text("\(set.player1Points)").font(.system(size: 40, weight: .black))
                                        Spacer()
                                        Text("-").font(.system(size: 40, weight: .black))
                                        Spacer()
                                        Text("\(set.player2Points)").font(.system(size: 40, weight: .black))
                                        Spacer()
                                    }
                                    Divider().padding()
                                }
                            }
                    Spacer()
            }.confirmationDialog("Settings", isPresented: $settingTapped) {
                Button(role: .destructive) {
                    confirmDeleteAlert.toggle()
                } label: {
                    Text("Delete match")
                }

            }
            .alert(isPresented: $confirmDeleteAlert) {
                Alert(title: Text("Delete match"), message: Text("Are you sure you want to delete this match?"), primaryButton: .destructive(Text("Delete")){
                   // DELETE MATCH FUNCTION AND REMOVE STATS FROM PLAYERS
                    if isLeague { leagueVm.deleteMatch() } else {
                        tournamentVm.deleteMatch()
                    }
                    dismiss()
                }, secondaryButton: .cancel())
            }
    }
}

struct addSetsView_Previews: PreviewProvider {
    static var previews: some View {
        matchResultView()
    }
}

extension matchResultView{
    
    private var vsSection: some View{
        HStack{
            VStack
            {
                if leagueVm.currentMatch?.player1Pic ?? "" != "" || tournamentVm.currentMatch?.player1Pic ?? "" != ""{
                    WebImage(url: isLeague ? URL(string: leagueVm.currentMatch!.player1Pic) : URL(string: tournamentVm.currentMatch!.player1Pic))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding(.horizontal)
                        .padding(.top)
                        
                }
                else {
                    Image("profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding(.horizontal)
                }
                
                Text(isLeague ? leagueVm.currentMatch?.player1DisplayName ?? "Oponent" : tournamentVm.currentMatch?.player1DisplayName ?? "Oponent")
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(width: 100, height: 50)
            }
            Text("VS")
                .font(.system(size: 20, weight: .bold))
                .offset(y: -25)
            
            VStack{
                if leagueVm.currentMatch?.player2Pic ?? "" != "" || tournamentVm.currentMatch?.player2Pic ?? "" != ""{
                    WebImage(url: isLeague ? URL(string: leagueVm.currentMatch!.player2Pic) : URL(string: tournamentVm.currentMatch!.player2Pic))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding(.horizontal)
                        .padding(.top)
                }
                else {
                    Image("profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding(.horizontal)
                }
                
                
                Text(isLeague ? leagueVm.currentMatch?.player2DisplayName ?? "Oponent" : tournamentVm.currentMatch?.player2DisplayName ?? "Oponent")
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(width: 100, height: 50)
            }
        }.padding(.vertical)
    }
//    private var vsSection: some View {
//        HStack{
//            VStack
//            {
//                WebImage(url: URL(string: leagueVm.currentMatch!.player1Pic))
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 100, height: 100)
//                    .clipShape(Circle())
//                    .shadow(radius: 20)
//                    .padding(.horizontal)
//
//                Text(leagueVm.currentMatch!.player1DisplayName)
//                    .font(.system(size: 15, weight: .bold))
//                    .multilineTextAlignment(.leading)
//                    .frame(width: 100, height: 50)
//            }
//
//            Text("VS")
//                .font(.system(size: 20, weight: .bold))
//                .offset(y: -25)
//
//            VStack
//            {
//               WebImage(url: URL(string: leagueVm.currentMatch!.player2Pic))
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: 100, height: 100)
//                .clipShape(Circle())
//                .shadow(radius: 20)
//                .padding(.horizontal)
//
//            Text(leagueVm.currentMatch!.player2DisplayName)
//                .font(.system(size: 15, weight: .bold))
//                .multilineTextAlignment(.leading)
//                .frame(width: 100, height: 50)
//            }
//
//        }.padding(.vertical)
//    }
}
