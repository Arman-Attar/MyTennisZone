//
//  Match.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-12.
//

import Foundation

struct Match: Codable {
    let id: String
    let date: String
    let player1Pic: String
    let player2Pic: String
    let player1DisplayName: String
    let player2DisplayName: String
    var player1Score: Int
    var player2Score: Int
    var winner: String
    var matchOngoing: Bool
    let setsToWin: Int
    let matchType: String
}
