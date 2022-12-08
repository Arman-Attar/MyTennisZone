//
//  leagueVM.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-19.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class LeagueViewModel: ObservableObject {
    @Published var leagues: [League]?
    @Published var league: League?
    @Published var playerList: [Player] = []
    @State var topPlayer = ""
    @Published var listOfMatches: [Match] = []
    @Published var currentMatch: Match?
    @Published var currentSets: [Set] = []
    @Published var playerImages: [UIImage?] = []
    @Published var leagueLoaded = false
    @Published var playerIsJoined = false
    
    // REFACTORED
    func getLeagues() async{
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        do {
            let leagues = try await DatabaseManager.shared.getLeagues(userID: uid)
            await MainActor.run(body: {
                self.leagues = leagues
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    func getCurrentLeague(leagueId: String) async {
        do {
            let league = try await DatabaseManager.shared.getLeague(leagueID: leagueId)
            await MainActor.run(body: { [weak self] in
                playerList.removeAll()
                self?.league = league
                var players = league.players
                players.sort {
                    $0.points > $1.points
                }
                self?.playerList = players
                self?.listOfMatches = league.matches.reversed()
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    func loadImages() async{
        do {
            let images = try await ImageLoader.shared.getImages(playerList: self.playerList)
            await MainActor.run(body: {
                self.playerImages = images
                self.leagueLoaded = true
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    func findLeague(leagueName: String, playerID: String) async{
        await MainActor.run(body: {
            self.league = nil
        })
        do {
            if let league = try await DatabaseManager.shared.searchLeague(leagueName: leagueName) {
                await MainActor.run(body: { [weak self] in
                    self?.league = league
                    self?.playerList = league.players
                })
            }
        } catch {
            print(error.localizedDescription)
            await MainActor.run(body: {
                self.league = nil

            })
        }
        let userStatus = await isUserJoined(playerID: playerID)
        await MainActor.run(body: {
            self.playerIsJoined = userStatus
        })
    }
    
    func isUserJoined(playerID: String) async -> Bool {
        let result = self.playerList.filter{playerID == $0.uid}
        return !result.isEmpty
    }
    
    
    // TO BE REFACTORED
    
    func joinLeague(uid: String, profilePic: String, displayName: String){
        let playerData = Player(uid: uid, profilePicUrl: profilePic, displayName: displayName, points: 0, wins: 0, losses: 0)
        guard let currentLeague = league else {return}
        DatabaseManager.shared.joinLeague(playerData: playerData, leagueID: currentLeague.id)
    }
    
    func getCurrentMatch(matchId: String) {
        self.currentSets = []
        for match in listOfMatches {
            if match.id == matchId{
                self.currentMatch = match
            }
        }
        
        FirebaseManager.shared.firestore.collection("sets").whereField("matchId", isEqualTo: matchId).getDocuments { snapshot, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            let sets = snapshot!.documents
            for set in sets {
                do{
                    let jsonData = try JSONSerialization.data(withJSONObject: set.data())
                    self.currentSets.append(try JSONDecoder().decode(Set.self, from: jsonData))
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func addSet(p1Points: Int, p2Points: Int) {
        var p1Uid = ""
        var p2Uid = ""
        let setid = UUID().uuidString
        for player in league!.players {
            if player.displayName == currentMatch!.player1DisplayName{
                p1Uid = player.uid
            }
            else if player.displayName == currentMatch!.player2DisplayName {
                p2Uid = player.uid
            }
        }
        
        let setInfo = ["setId" : setid, "matchId" : currentMatch!.id, "winner" : p1Points > p2Points ? p1Uid : p2Uid, "player1Uid" : p1Uid, "player2Uid" : p2Uid, "player1Points" : p1Points, "player2Points" : p2Points] as [String:Any]
        
        FirebaseManager.shared.firestore.collection("sets").document(setid).setData(setInfo) { err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
        }
        currentSets.append(Set(setId: setid, matchId: currentMatch!.id, winner: p1Points > p2Points ? p1Uid : p2Uid, player1Uid: p1Uid, player2Uid: p2Uid, player1Points: p1Points, player2Points: p2Points))
    }
    
    func updateMatch(ongoing: Bool){
        var player1Score = 0
        var player2Score = 0
        for set in currentSets {
            if set.player1Points > set.player2Points {
                player1Score += 1
            }
            else{
                player2Score += 1
            }
        }
        var winner = ""
        if !ongoing {
            if player1Score > player2Score {
                winner = currentMatch!.player1DisplayName
            }
            else{
                winner = currentMatch!.player2DisplayName
            }
        }
        FirebaseManager.shared.firestore.collection("leagues").document(league!.id).getDocument { snapshot, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            guard let doc = snapshot?.data() else {return}
            var matches = (doc["matches"] as! [[String: Any]]).map{ match in
                return Match(
                    id: match["id"] as? String ?? "",
                    date: match["date"] as? String ?? "",
                    player1Pic: match["player1Pic"] as? String ?? "",
                    player2Pic: match["player2Pic"] as? String ?? "",
                    player1DisplayName: match["player1DisplayName"] as? String ?? "",
                    player2DisplayName: match["player2DisplayName"] as? String ?? "",
                    player1Score: match["player1Score"] as? Int ?? 0,
                    player2Score: match["player2Score"] as? Int ?? 0,
                    winner: match["winner"] as? String ?? "",
                    matchOngoing: match["matchOngoing"] as? Bool ?? false,
                    setsToWin: match["setsToWin"] as? Int ?? 0,
                    matchType: match["matchType"] as? String ?? "")
            }
            
            var matchIndex = -1
            for match in matches {
                matchIndex += 1
                if match.id == self.currentMatch!.id{
                    break
                }
            }
            matches[matchIndex].player1Score = player1Score
            matches[matchIndex].player2Score = player2Score
            matches[matchIndex].matchOngoing = ongoing
            matches[matchIndex].winner = winner
            
            FirebaseManager.shared.firestore.collection("leagues").document(self.league!.id).updateData(["matches" : FieldValue.delete()])
            
            for match in matches {
                let matchData = ["id" : match.id, "date" : match.date, "player1Pic" : match.player1Pic, "player2Pic" : match.player2Pic, "player1DisplayName" : match.player1DisplayName, "player2DisplayName" : match.player2DisplayName, "player1Score" : match.player1Score, "player2Score" : match.player2Score, "winner" : match.winner, "matchOngoing" : match.matchOngoing, "setsToWin" : match.setsToWin, "matchType" : match.matchType] as [String: Any]
                
                FirebaseManager.shared.firestore.collection("leagues").document(self.league!.id).updateData(["matches" : FieldValue.arrayUnion([matchData])])
            }
        }
        
    }

    
    
    
    func deleteLeague(leagueId: String){
        if league?.bannerURL ?? "" != "" {
            if let url = league!.bannerURL {
                let storageRef = FirebaseManager.shared.storage.reference(forURL: url)
                storageRef.delete { err in
                    print(err?.localizedDescription ?? "Error")
                }
            }
        }
        
        FirebaseManager.shared.firestore.collection("leagues").document(leagueId).delete { err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
        }
    }
    
    func deleteMatch(){
        if !currentMatch!.matchOngoing{
            FirebaseManager.shared.firestore.collection("leagues").document(league!.id).getDocument { snapshot, err in
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
                let winnerIndex = players.firstIndex(where: { $0.displayName == self.currentMatch!.winner})
                var loser = ""
                if self.currentMatch!.player1DisplayName == self.currentMatch!.winner {
                    loser = self.currentMatch!.player2DisplayName
                }
                else {
                    loser = self.currentMatch!.player1DisplayName
                }
                let loserIndex = players.firstIndex(where: { $0.displayName == loser})
                players[winnerIndex!].points -= 3
                players[winnerIndex!].wins -= 1
                players[loserIndex!].losses -= 1
                
                FirebaseManager.shared.firestore.collection("leagues").document(self.league!.id).updateData(["players" : FieldValue.delete()])
                
                for player in players {
                    
                    let playerData = ["uid" : player.uid, "profilePicUrl" : player.profilePicUrl, "displayName" : player.displayName, "points" : player.points, "wins" : player.wins, "losses" : player.losses] as [String: Any]
                    
                    FirebaseManager.shared.firestore.collection("leagues").document(self.league!.id).updateData(["players" : FieldValue.arrayUnion([playerData])])
                }
                FirebaseManager.shared.firestore.collection("users").document(players[winnerIndex!].uid).updateData(
                    ["matchesPlayed" : FieldValue.increment(-1.00)])
                
                FirebaseManager.shared.firestore.collection("users").document(players[winnerIndex!].uid).updateData(["matchesWon" : FieldValue.increment(-1.00)])
                
                FirebaseManager.shared.firestore.collection("users").document(players[loserIndex!].uid).updateData(["matchesPlayed" : FieldValue.increment(-1.00)])
                
            }
        }
        let matchData: [String: Any] = [
            "id" : self.currentMatch!.id as Any,
            "date" : self.currentMatch!.date,
            "player1Pic" : self.currentMatch!.player1Pic,
            "player2Pic" : self.currentMatch!.player2Pic,
            "player1DisplayName" : self.currentMatch!.player1DisplayName,
            "player2DisplayName" : self.currentMatch!.player2DisplayName,
            "player1Score" : self.currentMatch!.player1Score,
            "player2Score" : self.currentMatch!.player2Score,
            "winner" : self.currentMatch!.winner,
            "matchOngoing" : self.currentMatch!.matchOngoing,
            "setsToWin" : self.currentMatch!.setsToWin,
            "matchType" : self.currentMatch!.matchType
        ]
        
        FirebaseManager.shared.firestore.collection("sets").whereField("matchId", isEqualTo: currentMatch!.id).getDocuments { snapshot, err in
            if let err = err{
                print(err.localizedDescription)
                return
            }
            for set in snapshot!.documents{
                set.reference.delete()
            }
        }
        
        FirebaseManager.shared.firestore.collection("leagues").document(self.league!.id).updateData(["matches" : FieldValue.arrayRemove([matchData])])
    }
    
    func getPos(players: [Player], uid: String) -> Int {
        var pos: Int = 0
        for player in players {
            pos += 1
            if player.uid == uid {
                break
            }
        }
        return pos
    }
    
    static func updateImage(image: UIImage?, completionHandler: @escaping (_ data: String) -> Void){
        let uid = UUID().uuidString
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = image?.jpegData(compressionQuality: 0.5) else {
            completionHandler("")
            return
        }
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
                completionHandler(url.absoluteString)
            }
        }
    }
    
    static func createLeague(bannerURL: String, leagueName: String, playerId: [String], admin: String, players: [Player], completionHandler: @escaping (_ data: Bool) -> Void){
        let leagueId = UUID().uuidString
        let leagueData = ["id" : leagueId, "name" : leagueName, "playerId" : playerId ,"players" : [], "matches" : [], "bannerURL" : bannerURL, "admin" : admin] as [String : Any]
        
        FirebaseManager.shared.firestore.collection("leagues").document(leagueId).setData(leagueData) { err in
            if let err = err {
                print(err.localizedDescription)
                completionHandler(false)
            }
            for player in players{
                let playerData = ["uid" : player.uid, "profilePicUrl" : player.profilePicUrl, "displayName" : player.displayName, "points" : player.points, "wins" : player.wins, "losses" : player.losses] as [String: Any]
                
                FirebaseManager.shared.firestore.collection("leagues").document(leagueId).updateData(["players" : FieldValue.arrayUnion([playerData])])
            }
        }
        completionHandler(true)
    }
}
