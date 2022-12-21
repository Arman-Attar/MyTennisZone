//
//  leagueView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-11.
//

import SwiftUI
import SDWebImageSwiftUI

struct leagueView: View {
    @ObservedObject var leagueVm = LeagueViewModel()
    @EnvironmentObject var userVm: UserViewModel
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false){
                VStack{
                    if leagueVm.leagues != nil {
                        ForEach(leagueVm.leagues!, id: \.id){ index in
                            NavigationLink {
                                leagueDetailView(leagueVM: leagueVm, userVm: userVm) .navigationTitle(index.name).onAppear{
                                    Task {
                                        if let leagueID = index.id {
                                            await leagueVm.getCurrentLeague(leagueId: leagueID)
                                        }
                                    }
                                }
                            } label: {
                                let pos = Utilities.getPos(players: index.players, uid: userVm.user!.uid)
                                VStack{
                                    EventBannerView(leagueEvent: index, tournamentEvent: nil, pos: pos)
                                }
                                .padding()
                                .shadow(radius: 20)
                            }
                        }
                    } else {
                        ProgressView()
                    }
                }
            }.navigationTitle("Leagues")
        }.task {
            await leagueVm.getLeagues()
        }
    }
}

struct leagueView_Previews: PreviewProvider {
    static var previews: some View {
        leagueView().environmentObject(UserViewModel())
    }
}

