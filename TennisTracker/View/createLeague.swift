//
//  createLeague.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-17.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct createLeague: View {
    @State var leagueName = ""
    @State var opponentSelection = false
    @State var noOfGames = ""
    @ObservedObject var vm = UserViewModel()
    @State var players: [Player] = []
    @State var playerId: [String] = []
    
    var body: some View {
        Form{
            leagueBanner.padding()
            leagueNameField.padding(.vertical)
            VStack {
                HStack {
                    Text("Players")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding()
                    Spacer()
                    Image(systemName: "person.fill.badge.plus")
                    
                        .font(.title3)
                        .onTapGesture {
                            opponentSelection.toggle()
                        }
                        .padding()
                }
                if players.isEmpty{
                    HStack() {
                        Text("Add players to the league")
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                    }.padding()
                }
                else{
                    HStack(spacing: -20) {
                        ForEach(players, id:\.uid) { player in
                            WebImage(url: URL(string: player.profilePicUrl))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .shadow(radius: 20)
                        }
                    }.padding()
                }
            }
            HStack {
                Spacer()
                createButton.onTapGesture {
                    createLeague()
                }
                Spacer()
            }
        }.navigationTitle("Create a league")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $opponentSelection) {
                oponentSelectionView(players: $players, playerId: $playerId, vm: vm)
            }
            .onAppear{
                players.append(Player(uid: vm.user?.uid ?? "", profilePicUrl: vm.user?.profilePicUrl ?? "", displayName: vm.user?.displayName ?? "", points: 0, wins: 0, losses: 0, played: 0))
                playerId.append(vm.user?.uid ?? "")
            }
    }
}

struct createLeague_Previews: PreviewProvider {
    static var previews: some View {
        createLeague()
    }
}

extension createLeague {
    private var leagueBanner: some View {
        VStack{
            Image("league")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(20)
                .padding(8)
        }
    }
    
    private var leagueNameField: some View {
        VStack{
            HStack{
                TextField("Enter League Name", text: $leagueName)
                    .foregroundColor(.black)
                    .keyboardType(.emailAddress)
                Image(systemName: "plus")
                    .foregroundColor(.black)
            }.padding(.horizontal).padding(.horizontal)
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .padding(.horizontal)
                .foregroundColor(.black)
                .padding()
        }
    }
    
    private var opponentField: some View {
        HStack{
            if !players.isEmpty {
                Text("Opponent:").padding().frame(maxWidth: UIScreen.main.bounds.size.width / 3, maxHeight: 10)
                
                HStack(spacing: -20) {
                    ForEach(players, id:\.uid) { player in
                        WebImage(url: URL(string: player.profilePicUrl))
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .shadow(radius: 20)
                    }
                }
                
                Button {
                    opponentSelection.toggle()
                } label: {
                    Text("Add")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .padding()
                        .foregroundColor(.black)
                        .frame(maxWidth: UIScreen.main.bounds.size.width / 3, maxHeight: 10)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 100)
                            .stroke(Color.black, lineWidth: 0.8))
                        .padding()
                }
            }
            else {
                Text("Opponent:").padding().frame(maxWidth: UIScreen.main.bounds.size.width / 3, maxHeight: 10)
                Image("profile")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .shadow(radius: 20)
                    .padding(.horizontal)
                
                Button {
                    opponentSelection.toggle()
                } label: {
                    Text("Add")
                        .font(.subheadline)
                        .fontWeight(.heavy)
                        .padding()
                        .foregroundColor(.black)
                        .frame(maxWidth: UIScreen.main.bounds.size.width / 3, maxHeight: 10)
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 100)
                            .stroke(Color.black, lineWidth: 0.8))
                        .padding()
                }
            }
            
        }.padding(.horizontal)
    }
    
    private var createButton: some View {
        ZStack {
            Text("Create")
                .font(.title2)
                .fontWeight(.heavy)
                .padding()
                .foregroundColor(.black)
                .frame(maxWidth: UIScreen.main.bounds.size.width / 2, maxHeight: 20)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 100)
                    .stroke(Color.black, lineWidth: 0.8))
                .padding()
        }
    }
    
    func createLeague(){
        
        let leagueId = UUID().uuidString
        let leagueData = ["id" : leagueId, "name" : leagueName, "playerId" : playerId ,"players" : [], "matches" : []] as [String : Any]
        
        FirebaseManager.shared.firestore.collection("leagues").document(leagueId).setData(leagueData) { err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            for player in players{
                let playerData = ["uid" : player.uid, "profilePicUrl" : player.profilePicUrl, "displayName" : player.displayName, "points" : player.points, "wins" : player.wins, "losses" : player.losses] as [String: Any]
                
                FirebaseManager.shared.firestore.collection("leagues").document(leagueId).updateData(["players" : FieldValue.arrayUnion([playerData])])
                
            }
        }
    }
}
