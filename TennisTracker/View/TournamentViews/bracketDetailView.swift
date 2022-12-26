//
//  bracketDetailView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-07-31.
//

import SwiftUI
import SDWebImageSwiftUI

struct bracketDetailView: View {
    
    @ObservedObject var tournamentVm = TournamentViewModel()
    @EnvironmentObject var userVm: UserViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var selectedIndex = 5
    @State private var modifyMatch = false
    @State private var matchInfo = false
    @State var settingTapped = false
    @State var confirmDeleteAlert = false
    @State var matchId = ""
    @State var loser: String = ""
    @State var isLoading = false
    @State var refresh: Bool = false
    
    let rounds = ["ROUND OF 32", "ROUND OF 16", "QUARTER-FINALS", "SEMI-FINALS", "FINAL", "WINNER"]
    
    var body: some View {
        ZStack {
            VStack {
                if tournamentVm.tournament != nil {
                    Spacer()
                    ScrollView(.horizontal){
                        if tournamentVm.firstRound == "R32" {
                            HStack{
                                ForEach(0..<6) { index in
                                    Button {
                                        selectedIndex = index
                                    }label: {
                                        Text(rounds[index])
                                            .font(.headline)
                                            .foregroundColor(selectedIndex == index ? Color.black : Color.gray)
                                    }
                                }.padding(10)
                            }.padding()
                        }
                        else if tournamentVm.firstRound == "R16" {
                            HStack{
                                ForEach(1..<6) { index in
                                    Button {
                                        selectedIndex = index
                                    } label: {
                                        Text(rounds[index])
                                            .font(.headline)
                                            .foregroundColor(selectedIndex == index ? Color.black : Color.gray)
                                    }
                                }.padding(10)
                            }.padding()
                        }
                        else if tournamentVm.firstRound == "QF" {
                            HStack{
                                ForEach(2..<6) { index in
                                    Button {
                                        selectedIndex = index
                                    } label: {
                                        Text(rounds[index])
                                            .font(.headline)
                                            .foregroundColor(selectedIndex == index ? Color.black : Color.gray)
                                    }
                                }.padding(10)
                            }.padding()
                        }
                        else if tournamentVm.firstRound == "SEMI" {
                            HStack{
                                ForEach(3..<6) { index in
                                    Button {
                                        selectedIndex = index
                                    } label: {
                                        Text(rounds[index])
                                            .font(.headline)
                                            .foregroundColor(selectedIndex == index ? Color.black : Color.gray)
                                    }
                                }.padding(10)
                            }.padding()
                        }
                        else {
                            HStack{
                                ForEach(4..<6) { index in
                                    Button {
                                        selectedIndex = index
                                    } label: {
                                        Text(rounds[index])
                                            .font(.headline)
                                            .foregroundColor(selectedIndex == index ? Color.black : Color.gray)
                                    }
                                }.padding(10)
                            }.padding()
                        }
                    }
                    Spacer()
                    if tournamentVm.allMatchesFinished() && tournamentVm.playerList.count > 1{
                        Button {
                            Task {
                                await tournamentVm.endRound()
                                selectedIndex = selectedIndex
                            }
                            
                        } label: {
                            HStack {
                                Text("End Current Round").font(.title3).padding()
                                Image(systemName: "flag.2.crossed").font(.title3).padding()
                            }.foregroundColor(Color.black)
                        }
                    }
                    ScrollView{
                        if selectedIndex == 0 {
                            BracketMatchUpsview(listOfMatches: tournamentVm.listOfMatches, selectedIndex: selectedIndex, matchId: $matchId, modifyMatch: $modifyMatch, matchInfo: $matchInfo)
                        }
                        else if selectedIndex == 1{
                            BracketMatchUpsview(listOfMatches: tournamentVm.listOfMatches, selectedIndex: selectedIndex, matchId: $matchId, modifyMatch: $modifyMatch, matchInfo: $matchInfo)
                        }
                        else if selectedIndex == 2{
                            BracketMatchUpsview(listOfMatches: tournamentVm.listOfMatches, selectedIndex: selectedIndex, matchId: $matchId, modifyMatch: $modifyMatch, matchInfo: $matchInfo)
                        }
                        else if selectedIndex == 3{
                            BracketMatchUpsview(listOfMatches: tournamentVm.listOfMatches, selectedIndex: selectedIndex, matchId: $matchId, modifyMatch: $modifyMatch, matchInfo: $matchInfo)
                        }
                        else if selectedIndex == 4{
                            BracketMatchUpsview(listOfMatches: tournamentVm.listOfMatches, selectedIndex: selectedIndex, matchId: $matchId, modifyMatch: $modifyMatch, matchInfo: $matchInfo)
                        }
                        else if selectedIndex == 5{
                            TournamentWinnerView(tournamentVm: tournamentVm)
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            .sheet(isPresented: $modifyMatch, onDismiss: {
                Task {
                    if refresh {
                        await tournamentVm.removePlayer(player: loser)
                        selectedIndex = 5
                    }
                }
            } ,content: {
                if matchId != "" {
                    modifyMatchView(matchVM: MatchViewModel(id: tournamentVm.tournament!.id!, listOfMatches: tournamentVm.listOfMatches, playerList: tournamentVm.playersEntered, admin: tournamentVm.tournament!.admin, matchID: matchId), isLeague: false ,loser: $loser, refresh: $refresh)
                }
            })
            .sheet(isPresented: $matchInfo) {
                if matchId != "" {
                    matchResultView(matchVM: MatchViewModel(id: tournamentVm.tournament!.id!, listOfMatches: tournamentVm.listOfMatches, playerList: tournamentVm.playersEntered, admin: tournamentVm.tournament!.admin, matchID: matchId), isLeague: false)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if tournamentVm.tournament?.admin ?? "" == userVm.user!.uid{
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
                            await tournamentVm.getCurrentTournament(tournamentID: tournamentVm.tournament!.id!)
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
                        isLoading.toggle()
                        if await tournamentVm.deleteTournament(tournamentId: tournamentVm.tournament!.id!) {
                            await tournamentVm.getTournaments()
                            dismiss()
                        } else {
                            isLoading.toggle()
                        }
                    }
                }, secondaryButton: .cancel())
        }
            if isLoading {
                LoadingView()
            }
        }
    }
}

struct bracketDetailView_Previews: PreviewProvider {
    static var previews: some View {
        bracketDetailView()
    }
}

