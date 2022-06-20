//
//  addMatchView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-25.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct addMatchView: View {
    let matchId = UUID().uuidString
    @ObservedObject var leagueVm = LeagueViewModel()
    @State var player1: Player?
    @State var player2: Player?
    @State var player1Score: Int = 0
    @State var player2Score: Int = 0
    @State var showPlayerList = false
    @State var matchOngoing = false
    @State var playerNumber = 0
    @State var matchDate = Date.now
    @State var numberOfSets = 3
    @State var sets: [Set] = []
    @State var winner = ""
    @State var loser = ""
    @State var showWinnerSheet = false
    @State var showSetSheet = false
    @State var player1SetScore = 0
    @State var player2SetScore = 0
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            NavigationView {
                Form{
                    Text("Add Match")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    vsSection
                    DatePicker("Match Date:", selection: $matchDate, displayedComponents: .date).padding().font(.callout)
                    Picker("First To:", selection: $numberOfSets) {
                        ForEach(0..<6){ set in
                            Text("\(set)")
                        }
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
                                WebImage(url: URL(string: winner == player1!.uid ? player1!.profilePicUrl : player2!.profilePicUrl))
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
                }.navigationBarHidden(true)
                .sheet(isPresented: $showPlayerList) {
                    selectOpponent
            }
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


struct addMatchView_Previews: PreviewProvider {
    static var previews: some View {
        addMatchView()
    }
}

extension addMatchView {
    
    private var selectOpponent: some View {
        VStack{
            Text("Players")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            Divider().padding(.horizontal)
            Spacer()
            ScrollView {
                ForEach(leagueVm.league!.players, id: \.uid) { friend in
                    Button {
                        if playerNumber == 1 {
                            player1 = Player(uid: friend.uid, profilePicUrl: friend.profilePicUrl, displayName: friend.displayName, points: friend.points, wins: friend.wins, losses: friend.losses, played: friend.played)
                        }
                        else {
                            player2 = Player(uid: friend.uid, profilePicUrl: friend.profilePicUrl, displayName: friend.displayName, points: friend.points, wins: friend.wins, losses: friend.losses, played: friend.played)
                        }
                        showPlayerList.toggle()
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
    
    private var vsSection: some View {
        HStack{
            VStack
            {
                if player1?.profilePicUrl ?? "" != ""{
                    WebImage(url: URL(string: player1!.profilePicUrl))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding(.horizontal)
                        .onTapGesture {
                            playerNumber = 1
                            showPlayerList.toggle()
                        }
                }
                else {
                    Image("profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding(.horizontal)
                        .onTapGesture {
                            playerNumber = 1
                            showPlayerList.toggle()
                        }
                }
                
                Text(player1?.displayName ?? "Oponent")
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(width: 100, height: 50)
            }
            Text("VS")
                .font(.system(size: 20, weight: .bold))
                .offset(y: -25)
            
            VStack{
                if player2?.profilePicUrl ?? "" != ""{
                    WebImage(url: URL(string: player2!.profilePicUrl))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding(.horizontal)
                        .onTapGesture {
                            playerNumber = 2
                            showPlayerList.toggle()
                        }
                }
                else {
                    Image("profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding(.horizontal)
                        .onTapGesture {
                            playerNumber = 2
                            showPlayerList.toggle()
                        }
                }
                
                
                Text(player2?.displayName ?? "Oponent")
                    .font(.system(size: 15, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .frame(width: 100, height: 50)
            }
        }.padding(.vertical)
    }
    
    private var setPicker: some View {
        HStack{
            Picker("First To:", selection: $numberOfSets) {
                ForEach(0..<8){ set in
                    Text("\(set)")
                }
            }.padding()
//            Text("First To:").padding()
//            ForEach(0..<6) { index in
//                HStack {
//                    Image(systemName: numberOfSets == index ? "circle.circle.fill" : "circle.circle").font(.system(size: 20, weight: .semibold)).foregroundColor(Color.black)
//                    Text("\(index) Sets").font(.system(size: 15, weight: .regular))
//                }.padding(.horizontal)
//                    .onTapGesture {
//                        numberOfSets = index
//                    }
//
//            }
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
            if player1?.uid ?? "" != "" && player1?.uid ?? "" != ""{
                Text("Add")
                    .font(.title3)
                    .fontWeight(.bold)
                    .frame(width: UIScreen.main.bounds.size.width/4)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 1))
                    .onTapGesture {
                        createMatch()
                        dismiss()
                    }
            }
        }.padding()
    }
    
    private var addSetBottomSheet: some View {
        ZStack {
            NavigationView {
                Form{
                    Text("Enter Set Result").fontWeight(.bold).padding().zIndex(1.0)
                    HStack{
                        if player1?.profilePicUrl ?? "" != ""{
                            WebImage(url: URL(string: player1!.profilePicUrl))
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
                        
                        
                        if player2?.profilePicUrl ?? "" != ""{
                            WebImage(url: URL(string: player2!.profilePicUrl))
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
                    Picker("\(player1?.displayName ?? "Oponent") Score:", selection: $player1SetScore) {
                        ForEach(0..<8){ set in
                            Text("\(set)")
                        }
                    }.padding()
                    
                    Picker("\(player2?.displayName ?? "Oponent") Score:", selection: $player2SetScore) {
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
                                var setWinner = ""
                                if player1SetScore > player2SetScore { setWinner = player1?.uid ?? ""}
                                else { setWinner = player2?.uid ?? ""}
                                sets.append(Set(setId: UUID().uuidString, matchId: matchId, winner: setWinner, player1Uid: player1!.uid, player2Uid: player2!.uid, player1Points: player1SetScore, player2Points: player2SetScore))
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
                    if player1?.profilePicUrl ?? "" != ""{
                        WebImage(url: URL(string: player1!.profilePicUrl))
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
                    Text(player1?.displayName ?? "").font(.headline).padding()
                }.onTapGesture {
                    winner = player1?.uid ?? ""
                    loser = player2?.uid ?? ""
                    showWinnerSheet.toggle()
                }
                HStack{
                    if player2?.profilePicUrl ?? "" != ""{
                        WebImage(url: URL(string: player2!.profilePicUrl))
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
                    Text(player2?.displayName ?? "").font(.headline).padding()
                }.onTapGesture {
                    winner = player2?.uid ?? ""
                    loser = player1?.uid ?? ""
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
    
    private func createMatch(){
        
        setPlayerScores()
        let date = convertDateToString(date: matchDate)
        
        let matchData = ["id" : matchId, "date" : date, "player1Pic" : player1!.profilePicUrl, "player2Pic" : player2!.profilePicUrl, "player1DisplayName" : player1!.displayName, "player2DisplayName" : player2!.displayName ,"player1Score" : player1Score, "player2Score" : player2Score, "winner" : winner, "matchOngoing" : matchOngoing, "setsToWin" : numberOfSets] as [String: Any]
        
        FirebaseManager.shared.firestore.collection("leagues").document(leagueVm.league!.id).updateData(["matches" : FieldValue.arrayUnion([matchData])])
        
        addSet()
        
        updateStats()
    }
    
    private func addSet() {
        for set in sets {
            
            let setInfo = ["setId" : set.setId, "matchId" : matchId, "winner" : set.winner, "player1Uid" : set.player1Uid, "player2Uid" : set.player2Uid, "player1Points" : set.player1Points, "player2Points" : set.player2Points] as [String:Any]
            
            FirebaseManager.shared.firestore.collection("sets").document(set.setId).setData(setInfo) { err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
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
                if !sets.isEmpty{
                    ForEach(sets, id: \.setId) { set in
                        Text("\(set.player1Points)-\(set.player2Points)").font(.headline).fontWeight(.bold)
                        Divider()
                    }
                }
            }
        }
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
                let winnerIndex = players.firstIndex(where: { $0.uid == winner})
                let loserIndex = players.firstIndex(where: { $0.uid == loser})
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
                
                
            }
        }
    }
    
    private func setPlayerScores(){
        for set in sets {
            if set.player1Points > set.player2Points {
                player1Score += 1
            }
            else{
                player2Score += 1
            }
        }
    }
    
    private func convertDateToString(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, y"
        let result = formatter.string(from: date)
        return result
    }
}
