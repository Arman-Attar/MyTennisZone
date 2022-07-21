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
    
    init(){
        getTournaments()
    }
    
    private func getTournaments(){
        
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
                        setsToWin: match["setsToWin"] as? Int ?? 3)
                }
                
                let bannerURL = document["bannerURL"] as? String ?? ""
                
                let admin = document["admin"] as? String ?? ""
                players.sort {
                    $0.points > $1.points
                }
                self.tournaments.append(Tournament(id: id, name: name, playerId: playerId, players: players, matches: matches, bannerURL: bannerURL, admin: admin))
            }
        }
    }
}
