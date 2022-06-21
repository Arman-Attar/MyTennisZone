//
//  modifyMatchView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-31.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct modifyMatchView: View {
    @ObservedObject var leagueVm = LeagueViewModel()
    @Environment(\.dismiss) var dismiss
    @State var matchOngoing = true
    @State var winner = ""
    @State var loser = ""
    @State var showWinnerSheet = false
    @State var player1SetScore = 0
    @State var player2SetScore = 0
    @State var showSetSheet = false
    @State var set: [Set] = []
    @State var numberOfSets = 0
    var body: some View {
        ZStack{
            Form{
                Text("Modify Match")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                vsSection
                HStack{
                    Text("Match Date:")
                    Spacer()
                    Text("\(leagueVm.currentMatch?.date ?? "")")
                }.padding()
                HStack{
                    Text("First To:")
                    Spacer()
                    Text("\(leagueVm.currentMatch?.setsToWin ?? 2)")
                }.padding()
                Toggle("Match Ongoing?", isOn: $matchOngoing).padding()
                setResultField
                if !matchOngoing {
                    HStack{
                        Text("Match Winner:").padding()
                        Spacer()
                        if winner == "" {
                            Image("profile")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .shadow(radius: 20)
                                .padding(.horizontal)
                                .onTapGesture {
                                    showWinnerSheet.toggle()
                                }
                        }
                        else {
                            WebImage(url: URL(string: winner == leagueVm.currentMatch!.player1DisplayName ? leagueVm.currentMatch!.player1Pic : leagueVm.currentMatch!.player2Pic))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .shadow(radius: 20)
                                .padding(.horizontal)
                                .onTapGesture {
                                    showWinnerSheet.toggle()
                                }
                        }
                    }
                }
                buttons
            }
            
            if showSetSheet{
                Rectangle().ignoresSafeArea().opacity(0.5)
                addSetBottomSheet
            }
            if showWinnerSheet{
                Rectangle().ignoresSafeArea().opacity(0.5)
                addWinnerBottomSheet
            }
        }
    }
}

struct modifyMatchView_Previews: PreviewProvider {
    static var previews: some View {
        modifyMatchView()
    }
}

extension modifyMatchView{
    
    private var vsSection: some View{
        HStack{
            VStack
            {
                if leagueVm.currentMatch?.player1Pic ?? "" != ""{
                    WebImage(url: URL(string: leagueVm.currentMatch!.player1Pic))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding(.horizontal)
                        .padding(.top)
                        
                }
                else {
                    Image("profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding(.horizontal)
                }
                
                Text(leagueVm.currentMatch?.player1DisplayName ?? "Oponent")
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(width: 100, height: 50)
            }
            Text("VS")
                .font(.system(size: 20, weight: .bold))
                .offset(y: -25)
            
            VStack{
                if leagueVm.currentMatch?.player2Pic ?? "" != ""{
                    WebImage(url: URL(string: leagueVm.currentMatch!.player2Pic))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding(.horizontal)
                        .padding(.top)
                }
                else {
                    Image("profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding(.horizontal)
                }
                
                
                Text(leagueVm.currentMatch?.player2DisplayName ?? "Oponent")
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(width: 100, height: 50)
            }
        }.padding(.vertical)
    }
    
    private var setPicker: some View {
        HStack{
            Text("First To:").padding()
            ForEach(0..<2) { index in
                HStack {
                    Image(systemName: leagueVm.currentMatch!.setsToWin == 2*index+3 ? "circle.circle.fill" : "circle.circle").font(.system(size: 20, weight: .semibold)).foregroundColor(Color.black)
                    Text("\(2*index+3) Sets").font(.system(size: 15, weight: .regular))
                }.padding(.leading)
            }
        }
    }
    
    private var setResultField: some View {
        VStack {
            HStack{
                Text("Add Set Results").padding(.horizontal)
                Spacer()
                Button {
                    player1SetScore = 0
                    player2SetScore = 0
                    showSetSheet.toggle()
                } label: {
                    Image(systemName: "plus").padding(.horizontal)
                }
            }
            HStack{
                if !leagueVm.currentSets.isEmpty{
                    ForEach(leagueVm.currentSets, id: \.setId) { set in
                    Text("\(set.player1Points)-\(set.player2Points)").font(.headline).fontWeight(.bold)
                    Divider()
                }
                }
            }
        }
    }
    
    private var addSetBottomSheet: some View {
        ZStack {
            NavigationView {
                Form{
                    Text("Enter Set Result").fontWeight(.bold).padding().zIndex(1.0)
                    HStack{
                        if leagueVm.currentMatch?.player1Pic ?? "" != ""{
                            WebImage(url: URL(string: leagueVm.currentMatch!.player1Pic))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(radius: 20)
                                .padding()
                              
                        }
                        else {
                            Image("profile")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(radius: 20)
                                .padding()
                              
                        }
                        
                        Text("VS")
                            .font(.system(size: 20, weight: .bold)).zIndex(1.0)
                            
                        
                        if leagueVm.currentMatch?.player2Pic ?? "" != ""{
                            WebImage(url: URL(string: leagueVm.currentMatch!.player2Pic))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(radius: 20)
                                .padding()
                        }
                        else {
                            Image("profile")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(radius: 20)
                                .padding()
                            
                        }
                    }
                    Picker("\(leagueVm.currentMatch?.player1DisplayName ?? "Oponent") Score:", selection: $player1SetScore) {
                                ForEach(0..<8){ set in
                                    Text("\(set)")
                                }
                            }.padding()
                        
                    Picker("\(leagueVm.currentMatch?.player2DisplayName ?? "Oponent") Score:", selection: $player2SetScore) {
                                ForEach(0..<8){ set in
                                    Text("\(set)")
                                }
                            }.padding()
                    
                    HStack{
                        Text("Cancel")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(width: UIScreen.main.bounds.size.width/4)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1))
                            .onTapGesture {
                                showSetSheet.toggle()
                        }
                        Spacer()
                        Text("Add")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(width: UIScreen.main.bounds.size.width/4)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1))
                            .onTapGesture {
                                leagueVm.addSet(p1Points: player1SetScore, p2Points: player2SetScore)
                                showSetSheet.toggle()
                            }
                    }.padding()
                }.navigationBarHidden(true)
            }
            
        }.cornerRadius(20)
                .frame(width: UIScreen.main.bounds.size.width - 10, height: UIScreen.main.bounds.size.height / 1.7)
            .position(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY - 300)
    }
    
    private var addWinnerBottomSheet: some View {
        ZStack {
                Form{
                    Text("Select The Winner").fontWeight(.bold).padding()
                    HStack{
                        if leagueVm.currentMatch?.player1Pic ?? "" != ""{
                            WebImage(url: URL(string: leagueVm.currentMatch!.player1Pic))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(radius: 20)
                                .padding()
                        }
                        else {
                            Image("profile")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(radius: 20)
                                .padding()
                        }
                        Text(leagueVm.currentMatch?.player1DisplayName ?? "").font(.headline).padding()
                    }.onTapGesture {
                        winner = leagueVm.currentMatch!.player1DisplayName
                        loser = leagueVm.currentMatch!.player2DisplayName
                        showWinnerSheet.toggle()
                    }
                    HStack{
                        if leagueVm.currentMatch?.player2Pic ?? "" != ""{
                            WebImage(url: URL(string: leagueVm.currentMatch!.player2Pic))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(radius: 20)
                                .padding()
                              
                        }
                        else {
                            Image("profile")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(radius: 20)
                                .padding()
                              
                        }
                        Text(leagueVm.currentMatch?.player2DisplayName ?? "").font(.headline).padding()
                    }.onTapGesture {
                        winner = leagueVm.currentMatch!.player2DisplayName
                        loser = leagueVm.currentMatch!.player1DisplayName
                        showWinnerSheet.toggle()
                    }
                    HStack{
                        Spacer()
                        Text("Cancel")
                            .font(.headline)
                            .fontWeight(.bold)
                            .frame(width: UIScreen.main.bounds.size.width/1.5)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1))
                            .onTapGesture {
                                showWinnerSheet.toggle()
                        }
                    }
        }.cornerRadius(20)
                .frame(width: UIScreen.main.bounds.size.width - 10, height: UIScreen.main.bounds.size.height / 1.7)
            .position(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY - 300)
    }
    }
    
    private var buttons: some View{
        HStack{
            Text("Cancel")
                .font(.title3)
                .fontWeight(.bold)
                .frame(width: UIScreen.main.bounds.size.width/4)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1))
                .onTapGesture {
                dismiss()
            }
            Spacer()
            Text("Update")
                .font(.title3)
                .fontWeight(.bold)
                .frame(width: UIScreen.main.bounds.size.width/4)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1))
                .onTapGesture {
                    leagueVm.updateMatch(ongoing: matchOngoing)
                    updateStats()
                    dismiss()
                }
        }.padding()
    }
    
    private func updateStats() {
        if !matchOngoing {
            FirebaseManager.shared.firestore.collection("leagues").document(leagueVm.league!.id).getDocument { snapshot, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }

               guard let document = snapshot?.data() else {return}
                var players = (document["players"] as! [[String: Any]]).map{ player in
                    return Player(
                        uid: player["uid"] as? String ?? "",
                        profilePicUrl: player["profilePicUrl"] as? String ?? "",
                        displayName: player["displayName"] as? String ?? "",
                        points: player["points"] as? Int ?? 0,
                        wins: player["wins"] as? Int ?? 0,
                        losses: player["losses"] as? Int ?? 0,
                        played: player["played"] as? Int ?? 0)
                }
                let winnerIndex = players.firstIndex(where: { $0.displayName == winner})
                let loserIndex = players.firstIndex(where: { $0.displayName == loser})
                players[winnerIndex!].points += 3
                players[winnerIndex!].wins += 1
                players[loserIndex!].losses += 1
                players[winnerIndex!].played += 1
                players[loserIndex!].played += 1
                
                FirebaseManager.shared.firestore.collection("leagues").document(leagueVm.league!.id).updateData(["players" : FieldValue.delete()])
                
                for player in players {
                    
                    let playerData = ["uid" : player.uid, "profilePicUrl" : player.profilePicUrl, "displayName" : player.displayName, "points" : player.points, "wins" : player.wins, "losses" : player.losses] as [String: Any]
                    
                    FirebaseManager.shared.firestore.collection("leagues").document(leagueVm.league!.id).updateData(["players" : FieldValue.arrayUnion([playerData])])
                }
                
                FirebaseManager.shared.firestore.collection("users").document(players[winnerIndex!].uid).updateData(
                    ["matchesPlayed" : FieldValue.increment(1.00)])
                
                FirebaseManager.shared.firestore.collection("users").document(players[winnerIndex!].uid).updateData(["matchesWon" : FieldValue.increment(1.00)])
                
                FirebaseManager.shared.firestore.collection("users").document(players[loserIndex!].uid).updateData(["matchesPlayed" : FieldValue.increment(1.00)])
        
            }
    }
    }
}


