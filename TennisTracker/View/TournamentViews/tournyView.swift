//
//  tournyView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-11.
//

import SwiftUI
import SDWebImageSwiftUI

struct tournyView: View {
    @ObservedObject var tournamentVm = TournamentViewModel()
    @EnvironmentObject var userVm: UserViewModel
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false){
                VStack{
                    ForEach(tournamentVm.tournaments, id: \.id){ index in
                        NavigationLink {
                            if index.mode == "Round Robin"{
                                tournamentDetailView(userVm: userVm, tournamentVm: tournamentVm)
                                    .navigationTitle(index.name.capitalized).onAppear{
                                        Task {
                                            if let tournamentID = index.id {
                                                await tournamentVm.getCurrentTournament(tournamentID: tournamentID)
                                            }
                                        }
                                        
                                    }
                            } else {
                                bracketDetailView(tournamentVm: tournamentVm, userVm: userVm)
                                    .navigationTitle(index.name).onAppear{
                                        Task {
                                            await tournamentVm.getCurrentTournament(tournamentID: index.id!)
                                        }
                                    }
                            }
                        } label: {
                            VStack{
                                EventBannerView(leagueEvent: nil, tournamentEvent: index)
                            }
                        }
                        .padding()
                        .shadow(radius: 20)
                    }
                }
            }.navigationTitle("Tournaments")
        }.task {
            await tournamentVm.getTournaments()
        }
    }
}

struct tournyView_Previews: PreviewProvider {
    static var previews: some View {
        tournyView().environmentObject(UserViewModel())
    }
}
