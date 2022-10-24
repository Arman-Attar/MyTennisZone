//
//  tournamentVM.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-07-20.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class TournamentViewModel: ObservableObject {
    @Published var tournaments: [Tournament] = []
    @Published var tournament: Tournament?
    @Published var playerList: [Player] = []
    @Published var playersEntered: [Player] = []
    @Published var listOfMatches: [Match] = []
    @Published var currentMatch: Match?
    @Published var currentSets: [Set] = []
    @State var topPlayer = ""
    @Published var currentRound: String = ""
    @Published var firstRound: String = ""
    init(){
        getTournaments()
    }
    
    func getTournaments(){
        tournaments = []
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        FirebaseManager.shared.firestore.collection("tournaments").whereField("playerId", arrayContains: uid).getDocuments { snapshot, err in
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
                        winner: match["winner"] as? String ?? "",
                        matchOngoing: match["matchOngoing"] as? Bool ?? false,
                        setsToWin: match["setsToWin"] as? Int ?? 3,
                        matchType: match["matchType"] as? String ?? "")
                }
                
                let bannerURL = document["bannerURL"] as? String ?? ""
                
                let admin = document["admin"] as? String ?? ""
                
                let mode = document["mode"] as? String ?? ""
                
                let winner = document["winner"] as? String ?? ""
                players.sort {
                    $0.points > $1.points
                }
                self.tournaments.append(Tournament(id: id, name: name, playerId: playerId, players: players, matches: matches, bannerURL: bannerURL, admin: admin, mode: mode, winner: winner))
            }
        }
    }
    
    func getCurrentTournament(tournamentId: String) {
        FirebaseManager.shared.firestore.collection("tournaments").document(tournamentId).getDocument { snapshot, err in
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
                    winner: match["winner"] as? String ?? "",
                    matchOngoing: match["matchOngoing"] as? Bool ?? false,
                    setsToWin: match["setsToWin"] as? Int ?? 3,
                    matchType: match["matchType"] as? String ?? "")
            }
            
            let bannerURL = document["bannerURL"] as? String ?? ""
            
            let admin = document["admin"] as? String ?? ""
            
            let mode = document["mode"] as? String ?? ""
            
            let winner = document["winner"] as? String ?? ""
            players.sort {
                $0.points > $1.points
            }
            
            self.tournament = Tournament(id: id, name: name, playerId: playerId, players: players, matches: matches, bannerURL: bannerURL, admin: admin, mode: mode, winner: winner)
            
            self.playerList = self.tournament?.players ?? []
            
            self.listOfMatches = matches
            
            if !self.listOfMatches.isEmpty {
                self.firstRound = self.listOfMatches[0].matchType
            }
            else{
                if self.playerList.count == 32 || self.playerList.count == 31 {
                    self.firstRound = "R32"
                }
                else if self.playerList.count == 16 || self.playerList.count == 15 {
                    self.firstRound = "R16"
                }
                else if self.playerList.count == 8 || self.playerList.count == 7 {
                    self.firstRound = "QF"
                }
                else if self.playerList.count == 4 || self.playerList.count == 3 {
                    self.firstRound = "SEMI"
                }
                else {
                    self.firstRound = "FINAL"
                }
            }
            
            
            if !self.listOfMatches.isEmpty {
                let last = self.listOfMatches.endIndex - 1
                self.currentRound = self.listOfMatches[last].matchType
            }
            else{
                if self.playerList.count == 32 || self.playerList.count == 31 {
                    self.currentRound = "R32"
                }
                else if self.playerList.count == 16 || self.playerList.count == 15 {
                    self.currentRound = "R16"
                }
                else if self.playerList.count == 8 || self.playerList.count == 7 {
                    self.currentRound = "QF"
                }
                else if self.playerList.count == 4 || self.playerList.count == 3 {
                    self.currentRound = "SEMI"
                }
                else {
                    self.currentRound = "FINAL"
                }
            }
            self.playersEntered = self.playerList
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
                let matchType = match.matchType
                
                self.currentMatch = Match(id: id, date: date, player1Pic: player1Pic, player2Pic: player2Pic, player1DisplayName: player1DisplayName, player2DisplayName: player2DisplayName ,player1Score: player1Score, player2Score: player2Score, winner: winner, matchOngoing: matchOngoing, setsToWin: setsToWin, matchType: matchType)
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
        for player in tournament!.players {
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
        var loser = ""
        if !ongoing {
            if player1Score > player2Score {
                winner = currentMatch!.player1DisplayName
                loser = currentMatch!.player2DisplayName
            }
            else{
                winner = currentMatch!.player2DisplayName
                loser = currentMatch!.player1DisplayName
            }
        }
        FirebaseManager.shared.firestore.collection("tournaments").document(tournament!.id).getDocument { snapshot, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            guard let doc = snapshot?.data() else {return}
            
            let players = (doc["players"] as! [[String: Any]]).map{ player in
                return Player(
                    uid: player["uid"] as? String ?? "",
                    profilePicUrl: player["profilePicUrl"] as? String ?? "",
                    displayName: player["displayName"] as? String ?? "",
                    points: player["points"] as? Int ?? 0,
                    wins: player["wins"] as? Int ?? 0,
                    losses: player["losses"] as? Int ?? 0,
                    played: player["played"] as? Int ?? 0)
            }
            
            self.playerList = []
            self.playerList = players
            
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
            
            if winner != "" && !ongoing {
            for player in self.playerList {
                if player.displayName == loser {
                    let playerData: [String: Any] = [
                        "uid" : player.uid as Any,
                        "profilePicUrl": player.profilePicUrl,
                        "displayName": player.displayName,
                        "points": player.points,
                        "wins": player.wins,
                        "losses": player.losses,
                    ]
                    print(player)
                    FirebaseManager.shared.firestore.collection("tournaments").document(self.tournament!.id).updateData(["players" : FieldValue.arrayRemove([playerData])])
                    print("PLAYER REMOVED")
                }
                if let index = self.playerList.firstIndex(where: {$0.displayName == loser}){
                    self.playerList.remove(at: index)
                }
            }
            }
            
            FirebaseManager.shared.firestore.collection("tournaments").document(self.tournament!.id).updateData(["matches" : FieldValue.delete()])
            
            for match in matches {
                let matchData = ["id" : match.id, "date" : match.date, "player1Pic" : match.player1Pic, "player2Pic" : match.player2Pic, "player1DisplayName" : match.player1DisplayName, "player2DisplayName" : match.player2DisplayName, "player1Score" : match.player1Score, "player2Score" : match.player2Score, "winner" : match.winner, "matchOngoing" : match.matchOngoing, "setsToWin" : match.setsToWin, "matchType" : match.matchType] as [String: Any]
                
                FirebaseManager.shared.firestore.collection("tournaments").document(self.tournament!.id).updateData(["matches" : FieldValue.arrayUnion([matchData])])
            }
        }
    }
    
    func deleteTournament(tournamentId: String){
        FirebaseManager.shared.firestore.collection("tournaments").document(tournamentId).delete { err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
        }
    }
    
    func allMatchesFinished() -> Bool {
        for match in listOfMatches {
            if match.matchOngoing {
                return false
            }
        }
        return true
    }
    
    func endRound() {
        var matches: [Match] = []
        if self.playerList.count > 0{
            if currentRound == "R32" {
                currentRound = "R16"
            }
            else if currentRound == "R16"{
                currentRound = "R8"
            }
            else if currentRound == "R8"{
                currentRound = "QF"
            }
            else if currentRound == "QF"{
                currentRound = "SEMI"
            }
            else if currentRound == "SEMI" {
                currentRound = "FINAL"
            }
            else{
                currentRound = "DONE"
            }
            if currentRound != "DONE"{
            if self.playerList.count % 2 == 0 {
                while self.playerList.count != 0 {
                    let match = Match(id: UUID().uuidString, date: convertDateToString(date: Date.now), player1Pic: playerList[0].profilePicUrl, player2Pic: playerList[1].profilePicUrl, player1DisplayName: playerList[0].displayName, player2DisplayName: playerList[1].displayName, player1Score: 0, player2Score: 0, winner: "", matchOngoing: true, setsToWin: self.listOfMatches[0].setsToWin, matchType: currentRound)
                        matches.append(match)
                        self.playerList.removeFirst()
                        self.playerList.removeFirst()
                }
            }
            else{
                while self.playerList.count != 1 {
                    let match = Match(id: UUID().uuidString, date: convertDateToString(date: Date.now), player1Pic: playerList[0].profilePicUrl, player2Pic: playerList[1].profilePicUrl, player1DisplayName: playerList[0].displayName, player2DisplayName: playerList[1].displayName, player1Score: 0, player2Score: 0, winner: "", matchOngoing: true, setsToWin: self.listOfMatches[0].setsToWin, matchType: currentRound)
                        matches.append(match)
                        self.playerList.removeFirst()
                        self.playerList.removeFirst()
            }
                let match = Match(id: UUID().uuidString, date: convertDateToString(date: Date.now), player1Pic: playerList[0].profilePicUrl, player2Pic: playerList[1].profilePicUrl, player1DisplayName: playerList[0].displayName, player2DisplayName: playerList[1].displayName, player1Score: 0, player2Score: 0, winner: "", matchOngoing: true, setsToWin: self.listOfMatches[0].setsToWin, matchType: currentRound)
                    matches.append(match)
        }
            
            for match in matches {
                let matchData = ["id" : match.id, "date" : match.date, "player1Pic" : match.player1Pic, "player2Pic" : match.player2Pic, "player1DisplayName" : match.player1DisplayName, "player2DisplayName" : match.player2DisplayName ,"player1Score" : match.player1Score, "player2Score" : match.player2Score, "winner" : match.winner, "matchOngoing" : match.matchOngoing, "setsToWin" : match.setsToWin, "matchType" : match.matchType] as [String: Any]
                
                FirebaseManager.shared.firestore.collection("tournaments").document(self.tournament!.id).updateData(["matches" : FieldValue.arrayUnion([matchData])])
            }
            }
            else {
                let winnerIndex = listOfMatches.endIndex - 1
                let winner = listOfMatches[winnerIndex].winner
                print(listOfMatches[winnerIndex])
                print(winner)
                FirebaseManager.shared.firestore.collection("tournaments").document(self.tournament!.id).updateData(["winner" : winner])
                FirebaseManager.shared.firestore.collection("users").document(self.playerList[0].uid).updateData(["trophies" : FieldValue.increment(1.00)])
            }
    }
        refreshData(tournamentId: tournament!.id)
    }
    
    private func convertDateToString(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, y"
        let result = formatter.string(from: date)
        return result
    }
    
    func refreshData(tournamentId: String){
        tournament = nil
        FirebaseManager.shared.firestore.collection("tournaments").document(tournamentId).getDocument { snapshot, err in
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
                    winner: match["winner"] as? String ?? "",
                    matchOngoing: match["matchOngoing"] as? Bool ?? false,
                    setsToWin: match["setsToWin"] as? Int ?? 3,
                    matchType: match["matchType"] as? String ?? "")
            }
            
            let bannerURL = document["bannerURL"] as? String ?? ""
            
            let admin = document["admin"] as? String ?? ""
            
            let mode = document["mode"] as? String ?? ""
            
            let winner = document["winner"] as? String ?? ""
            players.sort {
                $0.points > $1.points
            }
            
            self.tournament = Tournament(id: id, name: name, playerId: playerId, players: players, matches: matches, bannerURL: bannerURL, admin: admin, mode: mode, winner: winner)
            
            self.playerList = self.tournament?.players ?? []
            
            self.listOfMatches = matches
            
            if !self.listOfMatches.isEmpty {
                self.firstRound = self.listOfMatches[0].matchType
            }
            else{
                if self.playerList.count == 32 || self.playerList.count == 31 {
                    self.firstRound = "R32"
                }
                else if self.playerList.count == 16 || self.playerList.count == 15 {
                    self.firstRound = "R16"
                }
                else if self.playerList.count == 8 || self.playerList.count == 7 {
                    self.firstRound = "QF"
                }
                else if self.playerList.count == 4 || self.playerList.count == 3 {
                    self.firstRound = "SEMI"
                }
                else {
                    self.firstRound = "FINAL"
                }
            }
            
            
            if !self.listOfMatches.isEmpty {
                let last = self.listOfMatches.endIndex - 1
                self.currentRound = self.listOfMatches[last].matchType
            }
            else{
                if self.playerList.count == 32 || self.playerList.count == 31 {
                    self.currentRound = "R32"
                }
                else if self.playerList.count == 16 || self.playerList.count == 15 {
                    self.currentRound = "R16"
                }
                else if self.playerList.count == 8 || self.playerList.count == 7 {
                    self.currentRound = "QF"
                }
                else if self.playerList.count == 4 || self.playerList.count == 3 {
                    self.currentRound = "SEMI"
                }
                else {
                    self.currentRound = "FINAL"
                }
            }
            self.playersEntered = self.playerList
        }
    }
}
