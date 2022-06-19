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
    @Published var leagues: [League] = []
    @Published var league: League?
    @Published var playerList: [Player] = []
    @State var topPlayer = ""
    @Published var listOfMatches: [Match] = []
    @Published var currentMatch: Match?
    @Published var currentSets: [Set] = []
    
    init(){
        getLeagues()
    }
    
    private func getLeagues(){
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        FirebaseManager.shared.firestore.collection("leagues").whereField("playerId", arrayContains: uid).getDocuments { snapshot, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            for document in snapshot!.documents {
                let id = document["id"] as? String ?? ""
                let name = document["name"] as? String ?? ""
                let playerId = document["playerId"] as? [String] ?? []
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
                
                let matches = (document["matches"] as! [[String: Any]]).map{ match in
                    return Match(
                        id: match["id"] as? String ?? "",
                        date: match["date"] as? String ?? "",
                        player1Pic: match["player1Pic"] as? String ?? "",
                        player2Pic: match["player2Pic"] as? String ?? "",
                        player1DisplayName: match["player1DisplayName"] as? String ?? "",
                        player2DisplayName: match["player2DisplayName"] as? String ?? "",
                        player1Score: match["player1Score"] as? Int ?? 0,
                        player2Score: match["player2Score"] as? Int ?? 0,
                        winner: match["wineer"] as? String ?? "",
                        matchOngoing: match["matchOngoing"] as? Bool ?? false,
                        setsToWin: match["setsToWin"] as? Int ?? 3)
                }
                
                players.sort {
                    $0.points > $1.points
                }
                self.leagues.append(League(id: id, name: name, playerId: playerId, players: players, matches: matches))
            }
        }
    }
    
    func getCurrentLeague(leagueId: String) {
        playerList = []
        FirebaseManager.shared.firestore.collection("leagues").document(leagueId).getDocument { snapshot, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            guard let document = snapshot?.data() else {return}
            
            let id = document["id"] as? String ?? ""
            let name = document["name"] as? String ?? ""
            let playerId = document["playerId"] as? [String] ?? []
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
            let matches = (document["matches"] as! [[String: Any]]).map{ match in
                return Match(
                    id: match["id"] as? String ?? "",
                    date: match["date"] as? String ?? "",
                    player1Pic: match["player1Pic"] as? String ?? "",
                    player2Pic: match["player2Pic"] as? String ?? "",
                    player1DisplayName: match["player1DisplayName"] as? String ?? "",
                    player2DisplayName: match["player2DisplayName"] as? String ?? "",
                    player1Score: match["player1Score"] as? Int ?? 0,
                    player2Score: match["player2Score"] as? Int ?? 0,
                    winner: match["wineer"] as? String ?? "",
                    matchOngoing: match["matchOngoing"] as? Bool ?? false,
                    setsToWin: match["setsToWin"] as? Int ?? 3)
            }
            
            players.sort {
                $0.points > $1.points
            }
            
            self.league = League(id: id, name: name, playerId: playerId, players: players, matches: matches)
            
            self.playerList = self.league?.players ?? []
            
            self.listOfMatches = matches
        }
    }
    
    private func getMatches(leagueId: String){
        self.listOfMatches = []
        FirebaseManager.shared.firestore.collection("leagues").document(leagueId).getDocument { snapshot, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            guard let document = snapshot?.data() else {return}
            let matches = document["matches"] as? [String] ?? []
            
            for match in matches {
                FirebaseManager.shared.firestore.collection("matches").document(match).getDocument { snapshot, err in
                    if let err = err {
                        print(err.localizedDescription)
                        return
                    }
                    
                    guard let doc = snapshot?.data() else {return}
                    let id = doc["id"] as? String ?? ""
                    let date = doc["date"] as? String ?? ""
                    let player1Pic = doc["player1Pic"] as? String ?? ""
                    let player2Pic = doc["player2Pic"] as? String ?? ""
                    let player1DisplayName = doc["player1DisplayName"] as? String ?? ""
                    let player2DisplayName = doc["player2DisplayName"] as? String ?? ""
                    let player1Score = doc["player1Score"] as? Int ?? 0
                    let player2Score = doc["player2Score"] as? Int ?? 0
                    let winner = doc["winner"] as? String ?? ""
                    let matchOngoing = doc["matchOngoing"] as? Bool ?? false
                    let setsToWin = doc["setsToWin"] as? Int ?? 3
                    
                    self.listOfMatches.append(Match(id: id, date: date, player1Pic: player1Pic, player2Pic: player2Pic, player1DisplayName: player1DisplayName, player2DisplayName: player2DisplayName ,player1Score: player1Score, player2Score: player2Score, winner: winner, matchOngoing: matchOngoing, setsToWin: setsToWin))
                }
            }
        }
    }
    
    func getCurrentMatch(matchId: String) {
        self.currentSets = []
        for match in listOfMatches {
            if match.id == matchId{
                
                let id = match.id
                let date = match.date
                let player1Pic = match.player1Pic
                let player2Pic = match.player2Pic
                let player1DisplayName = match.player1DisplayName
                let player2DisplayName = match.player2DisplayName
                let player1Score = match.player1Score
                let player2Score = match.player2Score
                let winner = match.winner
                let matchOngoing = match.matchOngoing
                let setsToWin = match.setsToWin
                
                self.currentMatch = Match(id: id, date: date, player1Pic: player1Pic, player2Pic: player2Pic, player1DisplayName: player1DisplayName, player2DisplayName: player2DisplayName ,player1Score: player1Score, player2Score: player2Score, winner: winner, matchOngoing: matchOngoing, setsToWin: setsToWin)
            }
        }
        
        FirebaseManager.shared.firestore.collection("sets").whereField("matchId", isEqualTo: matchId).getDocuments { snapshot, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            for set in snapshot!.documents {
                let matchId = set["matchId"] as? String ?? ""
                let player1Points = set["player1Points"] as? Int ?? 0
                let player1Uid = set["player1Uid"] as? String ?? ""
                let player2Points = set["player2Points"] as? Int ?? 0
                let player2Uid = set["player2Uid"] as? String ?? ""
                let setId = set["setId"] as? String ?? ""
                let winner = set["winner"] as? String ?? ""
                
                self.currentSets.append(Set(setId: setId, matchId: matchId, winner: winner, player1Uid: player1Uid, player2Uid: player2Uid, player1Points: player1Points, player2Points: player2Points))
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
            else if player.displayName == currentMatch!.player1DisplayName {
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
        
        print(self.currentSets)
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
                    setsToWin: match["setsToWin"] as? Int ?? 0)
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
            
            FirebaseManager.shared.firestore.collection("leagues").document(self.league!.id).updateData(["matches" : FieldValue.delete()])
            
            for match in matches {
                let matchData = ["id" : match.id, "date" : match.date, "player1Pic" : match.player1Pic, "player2Pic" : match.player2Pic, "player1DisplayName" : match.player1DisplayName, "player2DisplayName" : match.player2DisplayName, "player1Score" : match.player1Score, "player2Score" : match.player2Score, "winner" : match.winner, "matchOngoing" : match.matchOngoing, "setsToWin" : match.setsToWin] as [String: Any]
                
                FirebaseManager.shared.firestore.collection("leagues").document(self.league!.id).updateData(["matches" : FieldValue.arrayUnion([matchData])])
            }
        }
    }
    
    func findLeague(leagueName: String) {
        league = nil
        FirebaseManager.shared.firestore.collection("leagues").whereField("name", isEqualTo: leagueName).getDocuments { snapshot, err in
            if let err = err{
                print(err.localizedDescription)
                return
            }
            guard let data = snapshot?.documents else {return}
            
            for document in data{
            let id = document["id"] as? String ?? ""
            let name = document["name"] as? String ?? ""
            let playerId = document["playerId"] as? [String] ?? []
            let players = (document["players"] as! [[String: Any]]).map{ player in
                return Player(
                    uid: player["uid"] as? String ?? "",
                    profilePicUrl: player["profilePicUrl"] as? String ?? "",
                    displayName: player["displayName"] as? String ?? "",
                    points: player["points"] as? Int ?? 0,
                    wins: player["wins"] as? Int ?? 0,
                    losses: player["losses"] as? Int ?? 0,
                    played: player["played"] as? Int ?? 0)
            }
            
            self.league = League(id: id, name: name, playerId: playerId, players: players, matches: [])
            
            self.playerList = self.league?.players ?? []
            }
        }
    }
    
    func joinLeague(uid: String, profilePic: String, displayName: String){
        let playerData = ["uid" : uid, "profilePicUrl" : profilePic, "displayName" : displayName, "points" : 0, "wins" : 0, "losses" : 0] as [String: Any]
        FirebaseManager.shared.firestore.collection("leagues").document(league!.id).updateData(["players" : FieldValue.arrayUnion([playerData])])
        FirebaseManager.shared.firestore.collection("leagues").document(league!.id).updateData(["playerId" : FieldValue.arrayUnion([uid])])
    }
}
