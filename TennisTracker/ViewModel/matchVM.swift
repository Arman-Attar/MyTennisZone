//
//  matchVM.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-26.
//

import Foundation
import SwiftUI
import FirebaseFirestoreSwift
import FirebaseFirestore
import simd



class MatchViewModel: ObservableObject {
    @Published var listOfMatches: [Match] = []
    
    func getMatches(leagueId: String){
        listOfMatches = []
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
                        
                        print(self.listOfMatches.count)
                    }
            }
        }
    }
    }

//struct Match {
//    let id: String
//    let date: Date
//    let player1: Player
//    let player2: Player
//    let player1Score: Int
//    let player2Score: Int
//    let winner: String
//    let loser: String
//    let matchFinished: Bool
//    let setsToWin: Int
//}
