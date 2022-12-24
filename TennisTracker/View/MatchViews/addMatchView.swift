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
    @State var showWinnerSheet = false
    @State var showSetSheet = false
    @State var player1SetScore = 0
    @State var player2SetScore = 0
    @State var showAlert = false
    @State var isLoading = false
    @StateObject var matchVM: MatchViewModel
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            NavigationView {
                if !isLoading {
                Form{
                    Text("Add Match")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    vsSection
                    DatePicker("Match Date:", selection: $matchDate, displayedComponents: .date).padding(.horizontal).padding(.vertical, 2).font(.callout)
                    Picker("First To:", selection: $numberOfSets) {
                        ForEach(0..<6){ set in
                            Text("\(set)")
                        }
                    }.padding(.horizontal).padding(.vertical, 2)
                    
                    Toggle("Match Ongoing?", isOn: $matchOngoing).padding(.horizontal).padding(.vertical, 4)
                    setResultField.padding(.vertical, 4)
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
                                let winnerPic = winner == player1!.uid ? player1!.profilePicUrl : player2!.profilePicUrl
                                if winnerPic != "" {
                                    WebImage(url: URL(string: winnerPic))
                                        .userImageModifier(width: 50, height: 50)
                                        .padding(.horizontal)
                                        .onTapGesture {
                                            showWinnerSheet.toggle()
                                        }
                                } else {
                                    Image("profile")
                                        .userImageModifier(width: 50, height: 50)
                                        .padding(.horizontal)
                                        .onTapGesture {
                                            showWinnerSheet.toggle()
                                        }
                                }
                            }
                        }
                    }
                    buttons
                }.navigationBarHidden(true)
                    .sheet(isPresented: $showPlayerList) {
                        selectOpponent
                    }
                } else {
                    ProgressView()
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
        }.alert(isPresented: $showAlert){
            Alert(title: Text("Error!"), message: Text("Required number of sets not reached"), dismissButton: .default(Text("Got it!")))
        }
    }
}


//struct addMatchView_Previews: PreviewProvider {
//    static var previews: some View {
//        addMatchView()
//    }
//}

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
                ForEach(matchVM.playerList, id: \.uid) { friend in
                    Button {
                        if playerNumber == 1 {
                            player1 = Player(uid: friend.uid, profilePicUrl: friend.profilePicUrl, displayName: friend.displayName, points: friend.points, wins: friend.wins, losses: friend.losses)
                        }
                        else {
                            player2 = Player(uid: friend.uid, profilePicUrl: friend.profilePicUrl, displayName: friend.displayName, points: friend.points, wins: friend.wins, losses: friend.losses)
                        }
                        showPlayerList.toggle()
                    } label: {
                        HStack{
                            if friend.profilePicUrl != "" {
                                WebImage(url: URL(string: friend.profilePicUrl))
                                    .userImageModifier(width: 50, height: 50)
                                    .padding(.horizontal)
                            }
                            else {
                                Image("profile")
                                    .userImageModifier(width: 50, height: 50)
                                    .padding(.horizontal)
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
                        .userImageModifier(width: 100, height: 100)
                        .padding(.horizontal)
                        .onTapGesture {
                            playerNumber = 1
                            showPlayerList.toggle()
                        }
                }
                else {
                    Image("profile")
                        .userImageModifier(width: 100, height: 100)
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
                        .userImageModifier(width: 100, height: 100)
                        .padding(.horizontal)
                        .onTapGesture {
                            playerNumber = 2
                            showPlayerList.toggle()
                        }
                }
                else {
                    Image("profile")
                        .userImageModifier(width: 100, height: 100)
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
    
//    private var setPicker: some View {
//        HStack{
//            Picker("First To:", selection: $numberOfSets) {
//                ForEach(0..<8){ set in
//                    Text("\(set)")
//                }
//            }.padding()
//        }
//    }
    
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
                        if !matchOngoing && !verifyScore(){
                            showAlert = true
                        }
                        else{
                            Task {
                                isLoading = true
                                if await matchVM.createMatch(matchOngoing: matchOngoing, player1: player1!, player2: player2!, date: matchDate, setsToWin: numberOfSets, matchType: "league" , sets: sets, matchID: matchId) {
                                    dismiss()
                                }
                            }
                        }
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
                                .userImageModifier(width: 100, height: 100)
                                .padding()
                            
                        }
                        else {
                            Image("profile")
                                .userImageModifier(width: 100, height: 100)
                                .padding()
                            
                        }
                        
                        Text("VS")
                            .font(.system(size: 20, weight: .bold)).zIndex(1.0)
                        
                        
                        if player2?.profilePicUrl ?? "" != ""{
                            WebImage(url: URL(string: player2!.profilePicUrl))
                                .userImageModifier(width: 100, height: 100)
                                .padding()
                        }
                        else {
                            Image("profile")
                                .userImageModifier(width: 100, height: 100)
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
                                let set = Set(matchId: matchId, winner: setWinner, player1Uid: player1!.uid, player2Uid: player2!.uid, player1Points: player1SetScore, player2Points: player2SetScore)
                                sets.append(set)
                                Task {
                                    await matchVM.addSet(p1Points: player1Score, p2Points: player2Score, set: set)
                                }
                                showSetSheet.toggle()
                            }
                    }.padding()
                }.navigationBarHidden(true)
            }
            
        }.cornerRadius(20)
            .frame(width: UIScreen.main.bounds.size.width - 10, height: UIScreen.main.bounds.size.height / 1.4)
            .position(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY - 300)
    }
    
    private var addWinnerBottomSheet: some View {
        ZStack {
            Form{
                Text("Select The Winner").fontWeight(.bold).padding()
                HStack{
                    if player1?.profilePicUrl ?? "" != ""{
                        WebImage(url: URL(string: player1!.profilePicUrl))
                            .userImageModifier(width: 100, height: 100)
                            .padding()
                    }
                    else {
                        Image("profile")
                            .userImageModifier(width: 100, height: 100)
                            .padding()
                    }
                    Text(player1?.displayName ?? "").font(.headline).padding()
                }.onTapGesture {
                    winner = player1?.uid ?? ""
                    showWinnerSheet.toggle()
                }
                HStack{
                    if player2?.profilePicUrl ?? "" != ""{
                        WebImage(url: URL(string: player2!.profilePicUrl))
                            .userImageModifier(width: 100, height: 100)
                            .padding()
                        
                    }
                    else {
                        Image("profile")
                            .userImageModifier(width: 100, height: 100)
                            .padding()
                        
                    }
                    Text(player2?.displayName ?? "").font(.headline).padding()
                }.onTapGesture {
                    winner = player2?.uid ?? ""
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
                    ForEach(sets, id: \.id) { set in
                        Text("\(set.player1Points)-\(set.player2Points)").font(.headline).fontWeight(.bold)
                        Divider()
                    }
                }
            }
        }
    }
    
    private func verifyScore() -> Bool{
        (player1Score, player2Score) = Utilities.calculatePlayerScores(sets: sets)
        if player1Score == numberOfSets || player2Score == numberOfSets{
            return true
        }
        else {
            return false
        }
    }
}
