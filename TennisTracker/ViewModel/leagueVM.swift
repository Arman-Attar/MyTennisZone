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
    @ObservedObject var matchVm = MatchViewModel()
    @Published var leagues: [League] = []
    @Published var league: League?
    @Published var playerList: [Player] = []
    @State var topPlayer = ""
    @Published var listOfMatches: [Match] = []
    
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
                        losses: player["losses"] as? Int ?? 0)
                }
                
                
                //let matches = document["matches"] as? [String] ?? []
                
                var matches = (document["matches"] as! [[String: Any]]).map{ match in
                    return Match(
                        id: match["id"] as? String ?? "",
                        date: match["date"] as? Date ?? Date(),
                        player1Pic: match["player1Pic"] as? String ?? "",
                        player2Pic: match["player2Pic"] as? String ?? "",
                        player1DisplayName: match["player1DisplayName"] as? String ?? "",
                        player2DisplayName: match["player2DisplayName"] as? String ?? "",
                        player1Score: match["player1Score"] as? Int ?? 0,
                        player2Score: match["player2Score"] as? Int ?? 0,
                        winner: match["wineer"] as? String ?? "",
                        loser: match["loser"] as? String ?? "",
                        matchFinished: match["matchFinished"] as? Bool ?? false,
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
                    losses: player["losses"] as? Int ?? 0)
            }
            var matches = (document["matches"] as! [[String: Any]]).map{ match in
                return Match(
                    id: match["id"] as? String ?? "",
                    date: match["date"] as? Date ?? Date(),
                    player1Pic: match["player1Pic"] as? String ?? "",
                    player2Pic: match["player2Pic"] as? String ?? "",
                    player1DisplayName: match["player1DisplayName"] as? String ?? "",
                    player2DisplayName: match["player2DisplayName"] as? String ?? "",
                    player1Score: match["player1Score"] as? Int ?? 0,
                    player2Score: match["player2Score"] as? Int ?? 0,
                    winner: match["wineer"] as? String ?? "",
                    loser: match["loser"] as? String ?? "",
                    matchFinished: match["matchFinished"] as? Bool ?? false,
                    setsToWin: match["setsToWin"] as? Int ?? 3)
            }
            
            //let matches = document["matches"] as? [String] ?? []
            players.sort {
                $0.points > $1.points
            }
            
            //self.matchVm.getMatches(leagueId: id)
            
            self.league = League(id: id, name: name, playerId: playerId, players: players, matches: matches)
            
            self.playerList = self.league?.players ?? []
            
            self.listOfMatches = matches
            //self.getMatches(leagueId: id)
            
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
                    let date = doc["date"] as? Date ?? Date()
                    let player1Pic = doc["player1Pic"] as? String ?? ""
                    let player2Pic = doc["player2Pic"] as? String ?? ""
                    let player1DisplayName = doc["player1DisplayName"] as? String ?? ""
                    let player2DisplayName = doc["player2DisplayName"] as? String ?? ""
                    let player1Score = doc["player1Score"] as? Int ?? 0
                    let player2Score = doc["player2Score"] as? Int ?? 0
                    let winner = doc["winner"] as? String ?? ""
                    let loser = doc["loser"] as? String ?? ""
                    let matchFinished = doc["matchFinished"] as? Bool ?? false
                    let setsToWin = doc["setsToWin"] as? Int ?? 3
                    
                    self.listOfMatches.append(Match(id: id, date: date, player1Pic: player1Pic, player2Pic: player2Pic, player1DisplayName: player1DisplayName, player2DisplayName: player2DisplayName ,player1Score: player1Score, player2Score: player2Score, winner: winner, loser: loser, matchFinished: matchFinished, setsToWin: setsToWin))
                }
            }
        }
    }
}
