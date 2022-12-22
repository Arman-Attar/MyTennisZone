//
//  leagueDetailView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-19.
//

import SwiftUI
import SDWebImageSwiftUI

struct leagueDetailView: View {
    @State private var selectedIndex = 0
    var position = 1
    @State private var showSheet = false
    @State private var modifyMatch = false
    @State private var matchInfo = false
    @ObservedObject var leagueVM: LeagueViewModel
    @ObservedObject var userVm: UserViewModel
    @State var settingTapped = false
    @State var matchId: String = ""
    @State var confirmDeleteAlert = false
    @Environment(\.dismiss) var dismiss
    @State var loser: [String] = []
    var body: some View {
        VStack(alignment: .leading) {
            if leagueVM.league != nil {
                Picker("Tab View", selection: $selectedIndex, content: {
                    Text("Table").tag(0)
                    Text("Matches").tag(1)
                })
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                if selectedIndex == 0 {
                    HStack {
                        Text("Standings")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                        Spacer()
                        Button {
                            showSheet.toggle()
                        } label: {
                            Text("Add Match")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.black)
                        }.padding()
                        
                    }
                    ScrollView {
                        Standingloop
                    }
                }
                else {
                    Text("Match History")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    VStack{
                        ScrollView {
                            matchHistory
                        }
                    }
                }
                Spacer()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if leagueVM.league?.admin ?? "" == userVm.user!.uid{
                                Button {
                                    settingTapped.toggle()
                                } label: {
                                    Image(systemName: "gear")
                                }
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing){
                            Button {
                                Task {
                                    if let leagueID = leagueVM.league?.id {
                                        await leagueVM.getCurrentLeague(leagueId: leagueID)
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
                    .confirmationDialog("Settings", isPresented: $settingTapped) {
                        Button(role: .destructive) {
                            confirmDeleteAlert.toggle()
                        } label: {
                            Text("Delete league")
                        }
                        
                    }
                    .alert(isPresented: $confirmDeleteAlert) {
                        Alert(title: Text("Delete league"), message: Text("Are you sure you want to delete this league?"), primaryButton: .destructive(Text("Delete")){
                            Task {
                                if let leagueID = leagueVM.league?.id {
                                    let result = await leagueVM.deleteLeague(leagueID: leagueID)
                                    if result {
                                        dismiss()
                                    }
                                }
                            }
                        }, secondaryButton: .cancel())
                    }
            } else {
                ProgressView()
            }
        }.refreshable {
            Task {
                if let leagueID = leagueVM.league?.id {
                    await leagueVM.getCurrentLeague(leagueId: leagueID)
                }
            }
        }
        .sheet(isPresented: $showSheet) {
            addMatchView(matchVM: MatchViewModel(id: leagueVM.league!.id!, listOfMatches: leagueVM.listOfMatches, playerList: leagueVM.playerList, admin: leagueVM.league!.admin, matchID: nil))
        }
        .sheet(isPresented: $modifyMatch) {
            if matchId != "" {
                modifyMatchView(matchVM: MatchViewModel(id: leagueVM.league!.id!, listOfMatches: leagueVM.listOfMatches, playerList: leagueVM.playerList, admin: leagueVM.league!.admin, matchID: matchId), loser: $loser)
            }
        }
        .sheet(isPresented: $matchInfo) {
            if matchId != "" {
                matchResultView(matchVM: MatchViewModel(id: leagueVM.league!.id!, listOfMatches: leagueVM.listOfMatches, playerList: leagueVM.playerList, admin: leagueVM.league!.admin, matchID: matchId))
            }
        }
    }
}

//struct leagueDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        leagueDetailView()
//    }
//}

extension leagueDetailView{
    private var Standingloop: some View {
        VStack{
            ForEach(Array(leagueVM.playerList.enumerated()), id: \.offset) { index, player in
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
    
    private var matchHistory: some View {
        VStack {
            ForEach(leagueVM.listOfMatches, id: \.id) { match in
                Button {
                        matchId = match.id
                        if match.matchOngoing {
                            modifyMatch.toggle()
                        } else {
                            matchInfo.toggle()
                        }
                } label: {
                    VStack {
                        HStack {
                            Text("\(match.date)").foregroundColor(Color.black).font(.footnote)
                            Spacer()
                            if match.matchOngoing {
                                Text("Ongoing").font(.footnote).foregroundColor(Color.black)
                                Image(systemName: "circle.fill").foregroundColor(Color.green).font(.footnote)
                            }
                        }.padding(.horizontal).padding(.top, 10)
                        HStack{
                            Text("\(match.player1DisplayName)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(width: UIScreen.main.bounds.size.width / 4.5)
                                .fixedSize(horizontal: false, vertical: true)

                            if match.player1Pic != "" {
                                WebImage(url: URL(string: match.player1Pic))
                                    .userImageModifier(width: 40, height: 40)
                            } else {
                                Image("profile")
                                    .userImageModifier(width: 40, height: 40)
                            }
                            
                            Text("\(match.player1Score) - \(match.player2Score)")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .padding(5)

                            if match.player2Pic != "" {
                                WebImage(url: URL(string: match.player2Pic))
                                    .userImageModifier(width: 40, height: 40)
                            } else {
                                Image("profile")
                                    .userImageModifier(width: 40, height: 40)
                            }

                            Text("\(match.player2DisplayName)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(width: UIScreen.main.bounds.size.width / 4.5)
                                .fixedSize(horizontal: false, vertical: true)


                        }.padding(.leading)
                            .padding(.trailing)
                            .padding(.bottom, 10)
                    }
                }
                Divider().padding(.horizontal)
            }
        }
    }
  
}
