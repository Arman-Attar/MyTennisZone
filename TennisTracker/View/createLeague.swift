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
    //@ObservedObject var leagueVm = LeagueViewModel()
    @State var players: [Player] = []
    @State var playerId: [String] = []
    
    var body: some View {
        ScrollView{
            VStack{
                leagueBanner
                Divider().padding(15)
                leagueNameField
                Divider().padding(.horizontal)
                opponentField
                Divider().padding(.horizontal)
                noOfGamesField
                Divider().padding(.horizontal)
                createButton
            }.sheet(isPresented: $opponentSelection) {
                selectOpponent
            }
        }.navigationTitle("Create a League")
            .onAppear{
                players.append(Player(uid: vm.user?.uid ?? "", profilePicUrl: vm.user?.profilePicUrl ?? "", displayName: vm.user?.displayName ?? "", points: 0, wins: 0, losses: 0))
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
                .frame(width: UIScreen.main.bounds.size.width - 10, height: UIScreen.main.bounds.size.height / 3.8)
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
                        //.padding(8)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                    }
                }
                
                Button {
                    opponentSelection.toggle()
                } label: {
                    Text("Change")
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
            Button {
                createLeague()
            } label: {
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
    }
    
    private var noOfGamesField: some View {
        HStack{
            Text("Select the number of games:").padding()
            
            VStack {
                TextField("0", text: $noOfGames)
                    .keyboardType(.numberPad)
                    .frame(maxWidth: 50, maxHeight: 1)
                Rectangle()
                    .frame(maxWidth: 50, maxHeight: 1)
                    .padding(.horizontal)
                    .foregroundColor(.black)
                    .offset(x: -20, y: 5)
            }
        }.padding(.horizontal)
    }
    
    private var selectOpponent: some View {
        VStack{
            Text("Friends")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            Divider().padding(.horizontal)
            Spacer()
            ScrollView {
                ForEach(vm.friends, id: \.uid) {friend in
                    Button {
                        players.append(Player(uid: friend.uid, profilePicUrl: friend.profilePicUrl, displayName: friend.displayName, points: 0, wins: 0, losses: 0))
                        playerId.append(friend.uid)
                        opponentSelection.toggle()
                    } label: {
                        HStack{
                            if friend.profilePicUrl != "" {
                                WebImage(url: URL(string: friend.profilePicUrl))
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .shadow(radius: 20)
                                    .padding(.horizontal)
                            }
                            else {
                                Image("profile")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .shadow(radius: 20)
                                    .padding()
                            }
                            VStack(alignment: .leading){
                                
                                Text(friend.displayName)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                Text("@\(friend.username)")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                    }
                    Divider().padding(.horizontal)
                }
            }
            Spacer()
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


//struct Player{
//    let uid: String
//    let profilePicUrl: String
//    let displayName: String
//    let points: Int
//    let wins: Int
//    let losses: Int
//}


//struct League {
//    let id: String
//    let name: String
//    let players: [Player]
//    let matches: [String]
//}
