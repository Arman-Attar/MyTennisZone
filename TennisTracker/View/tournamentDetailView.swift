//
//  tournamentDetailView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-07-21.
//

import SwiftUI
import SDWebImageSwiftUI

struct tournamentDetailView: View {
    @State private var selectedIndex = 0
    var position = 1
    @State private var showSheet = false
    @State private var modifyMatch = false
    @State private var matchInfo = false
    @ObservedObject var leagueVM = LeagueViewModel()
    @ObservedObject var userVm = UserViewModel()
    @ObservedObject var matchVm = MatchViewModel()
    @ObservedObject var tournamentVm = TournamentViewModel()
    @State var settingTapped = false
    @State var matchId = ""
    @State var confirmDeleteAlert = false
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(alignment: .leading) {
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
            
        }
        .sheet(isPresented: $modifyMatch) {
            modifyMatchView(tournamentVm: tournamentVm ,isLeague: false)
        }
        .sheet(isPresented: $matchInfo) {
            matchResultView(leagueVm: leagueVM, userVm: userVm)
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
                leagueVM.deleteLeague(leagueId: leagueVM.league!.id)
                dismiss()
            }, secondaryButton: .cancel())
        }
    }
}

struct tournamentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        tournamentDetailView()
    }
}

extension tournamentDetailView{
    private var Standingloop: some View {
        VStack{
            ForEach(Array(tournamentVm.playerList.enumerated()), id: \.offset) { index, player in
                VStack {
                    HStack {
                        Text("\(index + 1).")
                            .font(.headline)
                            .padding(.leading)
                        WebImage(url: URL(string: player.profilePicUrl))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .shadow(radius: 20)
                            .padding()
                    
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
            ForEach(tournamentVm.listOfMatches, id: \.id) { match in
                Button {
                    tournamentVm.getCurrentMatch(matchId: match.id)
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
                                .frame(width: UIScreen.main.bounds.size.width / 4)


                            WebImage(url: URL(string: match.player1Pic))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .shadow(radius: 20)
                            
                            Text("\(match.player1Score) - \(match.player2Score)")
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .padding(5)

                            WebImage(url: URL(string: match.player2Pic))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .shadow(radius: 20)


                            Text("\(match.player2DisplayName)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .frame(width: UIScreen.main.bounds.size.width / 4)


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
