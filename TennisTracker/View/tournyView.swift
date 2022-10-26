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
                                    .navigationTitle(index.name).onAppear{
                                        tournamentVm.getCurrentTournament(tournamentId: index.id)
                                    }
                            } else {
                                bracketDetailView(tournamentVm: tournamentVm, userVm: userVm)
                                    .navigationTitle(index.name).onAppear{
                                        tournamentVm.getCurrentTournament(tournamentId: index.id)
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
        }
    }
}

struct tournyView_Previews: PreviewProvider {
    static var previews: some View {
        tournyView().environmentObject(UserViewModel())
    }
}
