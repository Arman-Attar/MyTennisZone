//
//  LeagueSummaryView.swift
//  MyTennisZone
//
//  Created by Arman Zadeh-Attar on 2022-12-24.
//

import SwiftUI
import SDWebImageSwiftUI

struct LeagueSummaryView: View {
    
    @EnvironmentObject private var vm: UserViewModel
    @ObservedObject var leagueVM: LeagueViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack{
                header
                statBar
                joinButton
            }.navigationTitle("League Summary")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.headline)
                        }
                    }
                }
        }
        
    }
}

struct LeagueSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        LeagueSummaryView(leagueVM: LeagueViewModel()).environmentObject(UserViewModel())
    }
}

extension LeagueSummaryView {
    private var header: some View {
        VStack{
            if let league = leagueVM.league{
                if league.bannerURL != "" {
                    WebImage(url: URL(string: league.bannerURL))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(20)
                        .frame(width: UIScreen.main.bounds.size.width - 10, height: UIScreen.main.bounds.size.height / 3.8)
                        .padding(8)
                    
                } else {
                    Image("league")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(20)
                        .frame(width: UIScreen.main.bounds.size.width - 10, height: UIScreen.main.bounds.size.height / 3.8)
                        .padding(8)
                }
                
                Text(league.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
            }
        }
    }
    private var statBar: some View {
        HStack{
            if let league = leagueVM.league {
                Spacer()
                VStack {
                    Text("\(league.players.count)")
                        .font(.callout)
                        .fontWeight(.bold)
                    Text("Players")
                        .font(.caption)
                }.padding()
                Spacer()
                HStack{
                    VStack {
                        Text("\(leagueVM.playerList[0].displayName)")
                            .font(.callout)
                            .fontWeight(.bold)
                        Text("Admin")
                            .font(.caption)
                    }
                    VStack{
                        if leagueVM.playerList[0].profilePicUrl != "" {
                            WebImage(url: URL(string: leagueVM.playerList[0].profilePicUrl))
                                .userImageModifier(width: 50, height: 50)
                                .padding()
                        } else {
                            Image("profile")
                                .userImageModifier(width: 50, height: 50)
                                .padding()
                        }
                    }.padding(.trailing)
                }
            }
        }.padding(.horizontal)
    }
    private var joinButton: some View {
        VStack {
            if leagueVM.playerIsJoined {
                HStack {
                    Image(systemName: "person.fill.checkmark").font(.title).foregroundColor(.black)
                    Text("Joined")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .padding()
                        .foregroundColor(.black)
                        .padding()
                    
                }.frame(maxWidth: UIScreen.main.bounds.size.width / 1.25, maxHeight: 50)
                    .overlay(RoundedRectangle(cornerRadius: 100)
                        .stroke(Color.black, lineWidth: 0.8))
                    .padding()
                    .offset(y: 9)
            } else {
                Button {
                    Task {
                        if let user = vm.user {
                            if await leagueVM.joinLeague(uid: user.uid, profilePic: user.profilePicUrl, displayName: user.displayName) {
                                dismiss()
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "person.fill.badge.plus").font(.title).foregroundColor(.black)
                        Text("Join")
                            .font(.title2)
                            .fontWeight(.heavy)
                            .padding()
                            .foregroundColor(.black)
                            .padding()
                        
                    }.frame(maxWidth: UIScreen.main.bounds.size.width / 1.25, maxHeight: 50)
                        .overlay(RoundedRectangle(cornerRadius: 100)
                            .stroke(Color.black, lineWidth: 0.8))
                        .padding()
                        .offset(y: 9)
                }
            }
        }
    }
}
