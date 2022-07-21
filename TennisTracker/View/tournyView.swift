//
//  tournyView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-11.
//

import SwiftUI
import SDWebImageSwiftUI

struct tournyView: View {
    @ObservedObject var leagueVm = LeagueViewModel()
    @ObservedObject var tournamentVm = TournamentViewModel()
    @ObservedObject var userVm = UserViewModel()
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false){
                VStack{
                    ForEach(tournamentVm.tournaments, id: \.id){ index in
                        NavigationLink {
                            leagueDetailView(leagueVM: leagueVm, userVm: userVm) .navigationTitle(index.name).onAppear{leagueVm.getCurrentLeague(leagueId: index.id)}
                        } label: {
                            VStack{
                                if index.bannerURL == ""{
                                Image("league")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width/1.2, height: UIScreen.main.bounds.height/4)
                                    .clipShape(Rectangle())
                                    .padding(.horizontal)
                                }
                                else {
                                    WebImage(url: URL(string: index.bannerURL!))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: UIScreen.main.bounds.width/1.2, height: UIScreen.main.bounds.height/4)
                                        .clipShape(Rectangle())
                                        .padding(.horizontal)
                                }
                                HStack {
                                    Text(index.name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    Spacer()
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.gray)
                                    Text("\(index.players.count)")
                                        .foregroundColor(.black)
                                    Rectangle().frame(width: 1, height: 20)
                                    Text("Round Robin") // PUT IN THE TOURNAMENT TYPE
                                        .foregroundColor(.black)
                                }
                                .padding()
                                Divider().padding(.horizontal)
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

struct tournyView_Previews: PreviewProvider {
    static var previews: some View {
        tournyView()
    }
}
