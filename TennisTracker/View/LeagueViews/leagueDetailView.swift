//
//  leagueDetailView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-19.
//

import SwiftUI
import SDWebImageSwiftUI

struct leagueDetailView: View {
    
    @ObservedObject var leagueVM: LeagueViewModel
    @EnvironmentObject private var userVm: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedIndex = 0
    @State private var showSheet = false
    @State private var modifyMatch = false
    @State private var matchInfo = false
    @State private var settingTapped = false
    @State private var matchId: String = ""
    @State private var confirmDeleteAlert = false
    @State private var loser: String = ""

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
                    StandingsView(playerList: leagueVM.playerList)
                }
                else {
                    Text("Match History")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    VStack{
                        MatchHistoryView(listOfMatches: leagueVM.listOfMatches, matchId: $matchId, modifyMatch: $modifyMatch, matchInfo: $matchInfo)
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
        }
        .refreshable {
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

struct leagueDetailView_Previews: PreviewProvider {
    static var previews: some View {
        leagueDetailView(leagueVM: LeagueViewModel()).environmentObject(UserViewModel())
    }
}

