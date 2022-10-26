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
                    ForEach(leagueVm.leagues, id: \.id){ index in
                        NavigationLink {
                            leagueDetailView(leagueVM: leagueVm, userVm: userVm) .navigationTitle(index.name).onAppear{leagueVm.getCurrentLeague(leagueId: index.id)}
                        } label: {
                            let pos = leagueVm.getPos(players: index.players, uid: userVm.user!.uid)
                            VStack{
                                EventBannerView(leagueEvent: index, tournamentEvent: nil, pos: pos)
                            }
                            .padding()
                            .shadow(radius: 20)
                        }
                    }
                }
            }.navigationTitle("Leagues")
        }
    }
}

struct leagueView_Previews: PreviewProvider {
    static var previews: some View {
        leagueView().environmentObject(UserViewModel())
    }
}

