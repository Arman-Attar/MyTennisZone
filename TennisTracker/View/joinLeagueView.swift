//
//  joinLeagueView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-06-03.
//

import SwiftUI

struct joinLeagueView: View {
    @State var leagueName = ""
    @ObservedObject var leagueVm = LeagueViewModel()
    @State var showSheet = false
    @ObservedObject var vm = UserViewModel()
    var body: some View {
        VStack{
            searchBar
            ScrollView {
                ForEach(0..<15){ num in
                    Divider().padding()
                }
            }
        }.navigationTitle("Join a League")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSheet) {
                VStack {
                    backButton.padding()
                    header
                    statBar
                    joinButton
                    Spacer()
                }
            }
    }
}

struct joinLeagueView_Previews: PreviewProvider {
    static var previews: some View {
        joinLeagueView()
    }
}

extension joinLeagueView {
    private var statBar: some View {
        HStack{
            Spacer()
            VStack {
                Text("\(leagueVm.league?.players.count ?? 0)")
                    .font(.callout)
                    .fontWeight(.bold)
                Text("Players")
                    .font(.caption)
            }.padding()
            Spacer()
            VStack {
                Text("\(leagueVm.league?.matches.count ?? 0)")
                    .font(.callout)
                    .fontWeight(.bold)
                Text("Matches Played")
                    .font(.caption)
            }.padding()
            Spacer()
        }.padding(.horizontal)
    }
    
    private var joinButton: some View {
        VStack {
                Button {
                    leagueVm.joinLeague(uid: vm.user!.uid, profilePic: vm.user!.profilePicUrl, displayName: vm.user!.displayName)
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
    
    private var header: some View {
        VStack{
            Image("league")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(20)
                .frame(width: UIScreen.main.bounds.size.width - 10, height: UIScreen.main.bounds.size.height / 3.8)
                .padding(8)
            
            Text(leagueVm.league?.name ?? "Test Name")
                .font(.title)
                .fontWeight(.bold)
                .padding()
        }
    }
    
    private var backButton: some View {
        VStack{
            Button {
                showSheet.toggle()
            } label: {
                HStack{
                    Image(systemName: "arrow.left")
                    Text("Back")
                    Spacer()
                }.padding()
            }
        }
    }
    
    private var searchBar: some View {
        HStack{
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search Leagues", text: $leagueName).foregroundColor(Color.black)
            }.padding()
                .background(Color.gray).opacity(0.5)
                .cornerRadius(50)
                .padding(.leading)
            Button {
                leagueVm.findLeague(leagueName: leagueName)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showSheet.toggle()
                }
            } label: {
                Text("Find")
                    .padding()
                    .foregroundColor(Color.black)
                    .font(.title3)
            }
        }
    }
}
