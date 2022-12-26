//
//  tournamentDetailView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-07-21.
//

import SwiftUI
import SDWebImageSwiftUI


struct tournamentDetailView: View {
    
    @EnvironmentObject var userVm: UserViewModel
    @ObservedObject var tournamentVm = TournamentViewModel()
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedIndex = 0
    @State private var showSheet = false
    @State private var modifyMatch = false
    @State private var matchInfo = false
    @State var settingTapped = false
    @State var matchId = ""
    @State var confirmDeleteAlert = false
    @State var loser: String = ""
    @State var isLoading = false
    @State var refresh = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                if tournamentVm.tournament != nil {
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
                        }
                        StandingsView(playerList: tournamentVm.playerList)
                    }
                    else {
                        Text("Match History")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding()
                        VStack{
                            MatchHistoryView(listOfMatches: tournamentVm.listOfMatches, matchId: $matchId, modifyMatch: $modifyMatch, matchInfo: $matchInfo)
                        }
                    }
                    Spacer()
                } else {
                    ProgressView()
                }
                
            }
            .sheet(isPresented: $modifyMatch, onDismiss: {
                if refresh {
                    Task {
                        if let tournamentID = tournamentVm.tournament?.id {
                            await tournamentVm.getCurrentTournament(tournamentID: tournamentID)
                        }
                    }
                }
            }, content: {
                if matchId != "" {
                    modifyMatchView(matchVM: MatchViewModel(id: tournamentVm.tournament!.id!, listOfMatches: tournamentVm.listOfMatches, playerList: tournamentVm.playerList, admin: tournamentVm.tournament!.admin, matchID: matchId), isLeague: false, loser: $loser, refresh: $refresh)
                }
            })
            .sheet(isPresented: $matchInfo, onDismiss: {
                if refresh {
                    Task {
                        if let tournamentID = tournamentVm.tournament?.id {
                            await tournamentVm.getCurrentTournament(tournamentID: tournamentID)
                        }
                    }
                }
            }, content: {
                if matchId != "" {
                    matchResultView(matchVM: MatchViewModel(id: tournamentVm.tournament!.id!, listOfMatches: tournamentVm.listOfMatches, playerList: tournamentVm.playerList, admin: tournamentVm.tournament!.admin, matchID: matchId), isLeague: false ,refresh: $refresh)
                }
            })
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
            .refreshable {
                Task {
                    if let tournmentID = tournamentVm.tournament?.id {
                        await tournamentVm.getCurrentTournament(tournamentID: tournmentID)
                    }
                }
        }
            if isLoading {
                LoadingView()
            }
        }
    }
}

struct tournamentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        tournamentDetailView()
    }
}
