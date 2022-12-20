//
//  joinLeagueView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-06-03.
//

import SwiftUI
import SDWebImageSwiftUI

struct joinLeagueView: View {
    @State var leagueName = ""
    @StateObject var leagueVm = LeagueViewModel()
    @State var showSheet = false
    @EnvironmentObject var vm: UserViewModel
    @State var notFoundAlert = false
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
            .alert(isPresented: $notFoundAlert){
                Alert(title: Text("Error!"), message: Text("League Not Found"), dismissButton: .default(Text("Got it!")))
            }
    }
}

struct joinLeagueView_Previews: PreviewProvider {
    static var previews: some View {
        joinLeagueView().environmentObject(UserViewModel())
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
            HStack{
                VStack {
                    Text("\(leagueVm.playerList[0].displayName)")
                        .font(.callout)
                        .fontWeight(.bold)
                    Text("Admin")
                        .font(.caption)
                }
                VStack{
                    if leagueVm.playerList[0].profilePicUrl != "" {
                        WebImage(url: URL(string: leagueVm.playerList[0].profilePicUrl))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .shadow(radius: 20)
                            .padding()
                    }
                }.padding(.trailing)
            }
        }.padding(.horizontal)
    }
    
    private var joinButton: some View {
        VStack {
            if leagueVm.playerIsJoined {
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
                       await leagueVm.joinLeague(uid: vm.user!.uid, profilePic: vm.user!.profilePicUrl, displayName: vm.user!.displayName)
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
    
    private var header: some View {
        VStack{
            Image("league")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(20)
                .frame(width: UIScreen.main.bounds.size.width - 10, height: UIScreen.main.bounds.size.height / 3.8)
                .padding(8)
            
            Text(leagueVm.league!.name)
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
                TextField("Search Leagues", text: $leagueName).foregroundColor(Color.black).disableAutocorrection(true)
            }.padding()
                .background(Color.gray).opacity(0.5)
                .cornerRadius(50)
                .padding(.leading)
            Button {
                let trimmedName = leagueName.trimmingCharacters(in: .whitespacesAndNewlines)
                Task {
                    await leagueVm.findLeague(leagueName: trimmedName.lowercased(), playerID: vm.user!.uid)
                    if leagueVm.league?.id ?? "" == ""{
                        notFoundAlert = true
                    }
                    else{
                        showSheet.toggle()
                    }
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
