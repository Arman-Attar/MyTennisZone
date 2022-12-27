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
    @State var showAlert = false
    @State var isLoading = false
    @State var noPlayerSelectedAlert = false
    @Binding var refresh: Bool
    @ObservedObject var matchVM: MatchViewModel
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
                        HeadToHeadView(player1: player1, player2: player2, playerNumber: $playerNumber, showPlayerList: $showPlayerList).padding(.horizontal)
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
                            SelectOponentView(playerNumber: $playerNumber, player1: $player1, player2: $player2, showPlayerList: $showPlayerList, playerList: matchVM.playerList)
                        }
                        .alert(isPresented: $noPlayerSelectedAlert){
                            Alert(title: Text("Error!"), message: Text("Please select the players first then input set scores"), dismissButton: .default(Text("Got it!")))
                        }
                } else {
                    LoadingView()
                }
            }
            if showSetSheet{
                Rectangle().ignoresSafeArea().opacity(0.5)
                AddSetView(player1: player1, player2: player2, matchID: matchId, matchVM: matchVM, noPlayerSelectedAlert: $noPlayerSelectedAlert ,showSetSheet: $showSetSheet, sets: $sets)
                
            }
            if showWinnerSheet{
                Rectangle().ignoresSafeArea().opacity(0.5)
                SelectWinnerView(showWinnerSheet: $showWinnerSheet, winner: $winner, player1: player1, player2: player2)
            }
        }.alert(isPresented: $showAlert){
            Alert(title: Text("Error!"), message: Text("Inalid number of sets and or winner selected!"), dismissButton: .default(Text("Got it!")))
        }
    }
}


struct addMatchView_Previews: PreviewProvider {
    static var previews: some View {
        addMatchView(refresh: .constant(true), matchVM: MatchViewModel(id: "", listOfMatches: [], playerList: [], admin: "", matchID: ""))
    }
}

extension addMatchView {
    
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
                                    refresh = true
                                    dismiss()
                                }
                            }
                        }
                    }
            }
        }.padding()
    }
    
    private var setResultField: some View {
        VStack {
            HStack{
                Text("Add Set Results").padding(.horizontal)
                Spacer()
                Button {
                    showSetSheet.toggle()
                } label: {
                    Image(systemName: "plus").padding(.horizontal)
                }
            }
            HStack{
                if !sets.isEmpty{
                    ForEach(Array(sets.enumerated()), id: \.offset) { _ , set in
                        Text("\(set.player1Points)-\(set.player2Points)").font(.headline).fontWeight(.bold)
                        Divider()
                    }
                }
            }
        }
    }
    
    private func verifyScore() -> Bool{
        (player1Score, player2Score) = Utilities.calculatePlayerScores(sets: sets)
        if player1Score == numberOfSets && winner == player1?.uid ?? "" {
            return true
        } else if player2Score == numberOfSets && winner == player2?.uid ?? "" {
            return true
        }
        else {
            return false
        }
    }
}

