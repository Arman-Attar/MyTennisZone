//
//  Utilities.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-15.
//

import Foundation

final class Utilities {
    
    static func convertDateToString(date: Date) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, y"
        let result = formatter.string(from: date)
        return result
    }
    
    static func calculatePlayerScores(sets: [Set]) -> (Int, Int) {
        var player1Score = 0
        var player2Score = 0
        for set in sets {
            if set.player1Points > set.player2Points {
                player1Score += 1
            }
            else{
                player2Score += 1
            }
        }
        return (player1Score, player2Score)
    }
    
}
