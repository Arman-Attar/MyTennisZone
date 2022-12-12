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
    @ObservedObject var tournamentVm = TournamentViewModel()
    @ObservedObject var userVm = UserViewModel()
    @State var isLeague = true
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
    @State var showAlert = false
    @State var deleteTapped = false
    @State var confirmDeleteAlert = false
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
                    Text(isLeague ? "\(leagueVm.currentMatch?.date ?? "")" : "\(tournamentVm.currentMatch?.date ?? "")")
                }.padding()
                HStack{
                    Text("First To:")
                    Spacer()
                    Text(isLeague ? "\(leagueVm.currentMatch?.setsToWin ?? 2)" : "\(tournamentVm.currentMatch?.setsToWin ?? 2)")
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
                            WebImage(url: isLeague ? URL(string: winner == leagueVm.currentMatch!.player1DisplayName ? leagueVm.currentMatch!.player1Pic : leagueVm.currentMatch!.player2Pic) : URL(string: winner == tournamentVm.currentMatch!.player1DisplayName ? tournamentVm.currentMatch!.player1Pic : tournamentVm.currentMatch!.player2Pic))
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
                Group{
                buttons
                if isLeague{
                    if leagueVm.league!.admin == userVm.user!.uid{
                    deleteButton
                    }
                }
                }
        }.alert(isPresented: $showAlert){
            Alert(title: Text("Error!"), message: Text("Required number of sets not reached"), dismissButton: .default(Text("Got it!")))
        }
        .confirmationDialog("Settings", isPresented: $deleteTapped) {
            Button(role: .destructive) {
                confirmDeleteAlert.toggle()
            } label: {
                Text("Delete match")
            }

        }
        .alert(isPresented: $confirmDeleteAlert) {
            Alert(title: Text("Delete match"), message: Text("Are you sure you want to delete this match?"), primaryButton: .destructive(Text("Delete")){
               // DELETE MATCH FUNCTION AND REMOVE STATS FROM PLAYERS
                if isLeague { leagueVm.deleteMatch() }
                dismiss()
            }, secondaryButton: .cancel())
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
                if leagueVm.currentMatch?.player1Pic ?? "" != "" || tournamentVm.currentMatch?.player1Pic ?? "" != ""{
                    WebImage(url: isLeague ? URL(string: leagueVm.currentMatch!.player1Pic) : URL(string: tournamentVm.currentMatch!.player1Pic))
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
                
                Text(isLeague ? leagueVm.currentMatch?.player1DisplayName ?? "Oponent" : tournamentVm.currentMatch?.player1DisplayName ?? "Oponent")
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(width: 100, height: 50)
            }
            Text("VS")
                .font(.system(size: 20, weight: .bold))
                .offset(y: -25)
            
            VStack{
                if leagueVm.currentMatch?.player2Pic ?? "" != "" || tournamentVm.currentMatch?.player2Pic ?? "" != ""{
                    WebImage(url: isLeague ? URL(string: leagueVm.currentMatch!.player2Pic) : URL(string: tournamentVm.currentMatch!.player2Pic))
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
                
                
                Text(isLeague ? leagueVm.currentMatch?.player2DisplayName ?? "Oponent" : tournamentVm.currentMatch?.player2DisplayName ?? "Oponent")
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
                    Image(systemName: isLeague ? leagueVm.currentMatch!.setsToWin == 2*index+3 ? "circle.circle.fill" : "circle.circle" : tournamentVm.currentMatch!.setsToWin == 2*index+3 ? "circle.circle.fill" : "circle.circle").font(.system(size: 20, weight: .semibold)).foregroundColor(Color.black)
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
                if !leagueVm.currentSets.isEmpty || !tournamentVm.currentSets.isEmpty{
                    ForEach(isLeague ? leagueVm.currentSets : tournamentVm.currentSets, id: \.setId) { set in
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
                        if leagueVm.currentMatch?.player1Pic ?? "" != "" || tournamentVm.currentMatch?.player1Pic ?? "" != ""{
                            WebImage(url: isLeague ? URL(string: leagueVm.currentMatch!.player1Pic) : URL(string: tournamentVm.currentMatch!.player1Pic))
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
                            
                        
                        if leagueVm.currentMatch?.player2Pic ?? "" != "" || tournamentVm.currentMatch?.player2Pic ?? "" != ""{
                            WebImage(url: isLeague ? URL(string: leagueVm.currentMatch!.player2Pic) : URL(string: tournamentVm.currentMatch!.player2Pic))
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
                    Picker(isLeague ? "\(leagueVm.currentMatch?.player1DisplayName ?? "Oponent")" : "\(tournamentVm.currentMatch?.player1DisplayName ?? "Oponent") Score:", selection: $player1SetScore) {
                                ForEach(0..<8){ set in
                                    Text("\(set)")
                                }
                            }.padding()
                        
                    Picker(isLeague ? "\(leagueVm.currentMatch?.player2DisplayName ?? "Oponent")" : "\(tournamentVm.currentMatch?.player2DisplayName ?? "Oponent") Score:", selection: $player2SetScore) {
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
                                if isLeague{
                                    leagueVm.addSet(p1Points: player1SetScore, p2Points: player2SetScore)
                                }
                                else {
                                    tournamentVm.addSet(p1Points: player1SetScore, p2Points: player2SetScore)
                                }
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
                        if leagueVm.currentMatch?.player1Pic ?? "" != "" || tournamentVm.currentMatch?.player1Pic ?? "" != ""{
                            WebImage(url: isLeague ? URL(string: leagueVm.currentMatch!.player1Pic) : URL(string: tournamentVm.currentMatch!.player1Pic))
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
                        Text(isLeague ? leagueVm.currentMatch?.player2DisplayName ?? "" : tournamentVm.currentMatch?.player2DisplayName ?? "").font(.headline).padding()
                    }.onTapGesture {
                        winner = isLeague ? leagueVm.currentMatch!.player1DisplayName : tournamentVm.currentMatch!.player1DisplayName
                        loser = isLeague ? leagueVm.currentMatch!.player2DisplayName : tournamentVm.currentMatch!.player2DisplayName
                        showWinnerSheet.toggle()
                    }
                    HStack{
                        if leagueVm.currentMatch?.player2Pic ?? "" != "" || tournamentVm.currentMatch?.player2Pic ?? "" != ""{
                            WebImage(url: isLeague ? URL(string: leagueVm.currentMatch!.player2Pic) : URL(string: tournamentVm.currentMatch!.player2Pic))
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
                        Text(isLeague ? leagueVm.currentMatch?.player2DisplayName ?? "" : tournamentVm.currentMatch?.player2DisplayName ?? "").font(.headline).padding()
                    }.onTapGesture {
                        winner = isLeague ? leagueVm.currentMatch!.player2DisplayName : tournamentVm.currentMatch!.player2DisplayName
                        loser = isLeague ? leagueVm.currentMatch!.player1DisplayName : tournamentVm.currentMatch!.player1DisplayName
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
                    if !matchOngoing && !verifyScore(){
                        showAlert = true
                    }
                    else{
                        updateStats()
                        if isLeague {
                            leagueVm.updateMatch(ongoing: matchOngoing)
                        }
                        else {
                            tournamentVm.updateMatch(ongoing: matchOngoing)
                        }
                        dismiss()
                    }
                }
        }.padding()
    }
    
    private func updateStats() {
        guard let leagueID = leagueVm.league?.id else { return }
        if !matchOngoing {
            
            FirebaseManager.shared.firestore.collection(isLeague ? "leagues" : "tournaments").document(isLeague ? leagueID : tournamentVm.tournament!.id).getDocument { snapshot, err in
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
                        losses: player["losses"] as? Int ?? 0)
                }
                let winnerIndex = players.firstIndex(where: { $0.displayName == winner})
                let loserIndex = players.firstIndex(where: { $0.displayName == loser})
                if isLeague || (!isLeague && tournamentVm.tournament!.mode == "Round Robin"){
                players[winnerIndex!].points += 3
                players[winnerIndex!].wins += 1
                players[loserIndex!].losses += 1
                
                FirebaseManager.shared.firestore.collection(isLeague ? "leagues" : "tournaments").document(isLeague ? leagueID : tournamentVm.tournament!.id).updateData(["players" : FieldValue.delete()])
                
                for player in players {
                    
                    let playerData = ["uid" : player.uid, "profilePicUrl" : player.profilePicUrl, "displayName" : player.displayName, "points" : player.points, "wins" : player.wins, "losses" : player.losses] as [String: Any]
                    
                    FirebaseManager.shared.firestore.collection(isLeague ? "leagues" : "tournaments").document(isLeague ? leagueID : tournamentVm.tournament!.id).updateData(["players" : FieldValue.arrayUnion([playerData])])
                }
                }
                FirebaseManager.shared.firestore.collection("users").document(players[winnerIndex!].uid).updateData(
                    ["matchesPlayed" : FieldValue.increment(1.00)])
                
                FirebaseManager.shared.firestore.collection("users").document(players[winnerIndex!].uid).updateData(["matchesWon" : FieldValue.increment(1.00)])
                
                FirebaseManager.shared.firestore.collection("users").document(players[loserIndex!].uid).updateData(["matchesPlayed" : FieldValue.increment(1.00)])
        
            }
    }
    }
    
    private func verifyScore() -> Bool{
        var player1Score = 0
        var player2Score = 0
        for set in isLeague ? leagueVm.currentSets : tournamentVm.currentSets {
            if set.player1Points > set.player2Points {
                player1Score += 1
            }
            else{
                player2Score += 1
            }
        }
        let setsToWin = isLeague ? leagueVm.currentMatch!.setsToWin : tournamentVm.currentMatch!.setsToWin
        if player1Score == setsToWin || player2Score == setsToWin {
            return true
        }
        else {
            return false
        }
    }
    
    private var deleteButton: some View {
        HStack{
            Spacer()
            Text("Delete Match")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color.red)
                .frame(width: UIScreen.main.bounds.size.width/3)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1))
                .onTapGesture {
                    deleteTapped.toggle()
        }
            Spacer()
        }.padding()
    }
}

