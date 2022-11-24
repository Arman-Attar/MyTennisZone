//
//  createRoundRobinTournment.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-06-24.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct createTournament: View {
    @State var tournamentName = ""
    @State var opponentSelection = false
    @State var noOfGames = ""
    @EnvironmentObject var vm: UserViewModel
    @State var players: [Player] = []
    @State var playerId: [String] = []
    @State var matches: [Match] = []
    @State var showImagePicker = false
    @State var image: UIImage?
    @State var numberOfSets = 2
    var modes = ["Bracket", "Round Robin"]
    @Environment(\.dismiss) var dismiss
    @State var mode = "Bracket"
    @State var matchGeneration = "Random"
    var bracketGeneration = "Random"
    @State var showAlert = false
    var body: some View {
        NavigationView {
            Form{
                leagueBanner.padding(.vertical)
                leagueNameField.padding(.vertical, 10)
                HStack {
                    Spacer()
                    Picker("First To:", selection: $numberOfSets) {
                        ForEach(0..<5){ set in
                            Text("\(set) Sets")
                        }
                    }
                }.padding()
                HStack {
                    Spacer()
                    Picker("Tournament Mode:", selection: $mode) {
                        ForEach(modes, id: \.self){ mode in
                            Text(mode)
                        }
                    }
                }.padding()
                if mode == "Bracket"{
                    HStack{
                        Text("Bracket Generation:").padding(.leading, 8)
                        Spacer()
                        Text("Random").padding(.trailing, 11)
                    }.padding()
                }
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
                HStack {
                    Spacer()
                    createButton.onTapGesture {
                        if verifyNumbOfPlayers(){
                            generateMatches()
                            if image != nil{
                                updateImage() // NEED TO FIX THIS, RIGHT NOW THIS FUNCTION ALSO CREATES THE LEAGUE
                            }
                            else{
                                createTournament(bannerURL: "")
                            }
                        }
                        else {
                            showAlert.toggle()
                        }
                    }
                    
                    Spacer()
                }
            }
            .sheet(isPresented: $opponentSelection) {
                opponentSelectionView(players: $players, playerId: $playerId, vm: vm)
            }
            .onAppear{
                if playerId.isEmpty {
                    players.append(Player(uid: vm.user?.uid ?? "", profilePicUrl: vm.user?.profilePicUrl ?? "", displayName: vm.user?.displayName ?? "", points: 0, wins: 0, losses: 0))
                    playerId.append(vm.user?.uid ?? "")
                }
            }
            .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
                ImagePicker(image: $image)
            }
            .navigationBarHidden(true)
            .alert(isPresented: $showAlert){
                Alert(title: Text("Error!"), message: Text("Number of players are not valid"), dismissButton: .default(Text("Got it!")))
            }
            .sheet(isPresented: $opponentSelection) {
                opponentSelectionView(players: $players, playerId: $playerId, vm: vm)
            }
            .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
                ImagePicker(image: $image)
            }
            
        }
        .navigationTitle("Create a tournament")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct createRoundRobinTournment_Previews: PreviewProvider {
    static var previews: some View {
        createTournament().environmentObject(UserViewModel())
    }
}


extension createTournament {
    
    
    private var leagueBanner: some View {
        VStack{
            if image != nil {
                Image(uiImage: image!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width/1.26, height: UIScreen.main.bounds.height/4)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        Image(systemName: "camera.fill").font(.title).foregroundColor(.white).opacity(0.8).padding([.top, .trailing], 5),
                        alignment: .topTrailing
                    )
                    .onTapGesture {
                        showImagePicker.toggle()
                    }
            }
            else {
                Image("league")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width/1.26, height: UIScreen.main.bounds.height/4)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        Image(systemName: "camera.fill").font(.title).foregroundColor(.white).opacity(0.8).padding([.top, .trailing], 5),
                        alignment: .topTrailing
                    )
                    .onTapGesture {
                        showImagePicker.toggle()
                    }
            }
        }
    }
    
    private var leagueNameField: some View {
        VStack{
            HStack{
                TextField("Enter League Name", text: $tournamentName)
                    .foregroundColor(.black)
                    .keyboardType(.emailAddress)
                Image(systemName: "plus")
                    .foregroundColor(.black)
            }.padding(.horizontal)
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 1)
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
    
    private func updateImage(){
        let uid = UUID().uuidString
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {return}
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            ref.downloadURL { url, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                guard let url = url else {return}
                createTournament(bannerURL: url.absoluteString)
            }
        }
    }
    
    func generateMatches(){
        var temp = players
        if mode == "Round Robin"{
            while temp.count != 1 {
                for i in 1..<temp.count {
                    let match = Match(id: UUID().uuidString, date: convertDateToString(date: Date.now), player1Pic: temp[0].profilePicUrl, player2Pic: temp[i].profilePicUrl, player1DisplayName: temp[0].displayName, player2DisplayName: temp[i].displayName, player1Score: 0, player2Score: 0, winner: "", matchOngoing: true, setsToWin: numberOfSets, matchType: "Round Robin")
                    matches.append(match)
                }
                temp.removeFirst()
            }
        }
        else if mode == "Bracket" && matchGeneration == "Random"{
            if temp.count % 2 == 0 {
                while temp.count != 0 {
                    let match = Match(id: UUID().uuidString, date: convertDateToString(date: Date.now), player1Pic: temp[0].profilePicUrl, player2Pic: temp[1].profilePicUrl, player1DisplayName: temp[0].displayName, player2DisplayName: temp[1].displayName, player1Score: 0, player2Score: 0, winner: "", matchOngoing: true, setsToWin: numberOfSets, matchType: getCurrentRound())
                    matches.append(match)
                    temp.removeFirst()
                    temp.removeFirst()
                }
            }
            else{
                while temp.count != 1 {
                    let match = Match(id: UUID().uuidString, date: convertDateToString(date: Date.now), player1Pic: temp[0].profilePicUrl, player2Pic: temp[1].profilePicUrl, player1DisplayName: temp[0].displayName, player2DisplayName: temp[1].displayName, player1Score: 0, player2Score: 0, winner: "", matchOngoing: true, setsToWin: numberOfSets, matchType: getCurrentRound())
                    matches.append(match)
                    temp.removeFirst()
                    temp.removeFirst()
                }
                let match = Match(id: UUID().uuidString, date: convertDateToString(date: Date.now), player1Pic: temp[0].profilePicUrl, player2Pic: "", player1DisplayName: temp[0].displayName, player2DisplayName: "", player1Score: numberOfSets, player2Score: 0, winner: "temp[0].displayName", matchOngoing: false, setsToWin: numberOfSets, matchType: getCurrentRound())
                matches.append(match)
            }
        }
    }
    
    func createTournament(bannerURL: String){
        
        let tournamentId = UUID().uuidString
        let admin = vm.user?.uid ?? ""
        tournamentName = tournamentName.trimmingCharacters(in: .whitespacesAndNewlines)
        let tournamentData = ["id" : tournamentId, "name" : tournamentName.lowercased(), "playerId" : playerId ,"players" : [], "matches" : [], "bannerURL" : bannerURL, "admin" : admin, "mode": mode, "winner": ""] as [String : Any]
        
        FirebaseManager.shared.firestore.collection("tournaments").document(tournamentId).setData(tournamentData) { err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            for player in players{
                let playerData = ["uid" : player.uid, "profilePicUrl" : player.profilePicUrl, "displayName" : player.displayName, "points" : player.points, "wins" : player.wins, "losses" : player.losses] as [String: Any]
                
                FirebaseManager.shared.firestore.collection("tournaments").document(tournamentId).updateData(["players" : FieldValue.arrayUnion([playerData])])
                
            }
            for match in matches {
                let matchData = ["id" : match.id, "date" : match.date, "player1Pic" : match.player1Pic, "player2Pic" : match.player2Pic, "player1DisplayName" : match.player1DisplayName, "player2DisplayName" : match.player2DisplayName ,"player1Score" : match.player1Score, "player2Score" : match.player2Score, "winner" : match.winner, "matchOngoing" : match.matchOngoing, "setsToWin" : match.setsToWin, "matchType" : match.matchType] as [String: Any]
                
                FirebaseManager.shared.firestore.collection("tournaments").document(tournamentId).updateData(["matches" : FieldValue.arrayUnion([matchData])])
            }
        }
    }
    
    private func convertDateToString(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, y"
        let result = formatter.string(from: date)
        return result
    }
    
    func getCurrentRound() -> String{
        if playerId.count == 32 || playerId.count == 31 {
            return "R32"
        }
        else if playerId.count == 16 || playerId.count == 15 {
            return "R16"
        }
        else if playerId.count == 8 || playerId.count == 7 {
            return "QF"
        }
        else if playerId.count == 4 || playerId.count == 3 {
            return "SEMI"
        }
        else {
            return "FINAL"
        }
    }
    
    func verifyNumbOfPlayers() -> Bool {
        if playerId.count == 32 || playerId.count == 31 || playerId.count == 16 || playerId.count == 15 || playerId.count == 8 || playerId.count == 7 || playerId.count == 4 || players.count == 3 || players.count == 2{
            return true
        }
        else {
            return false
        }
    }
}
