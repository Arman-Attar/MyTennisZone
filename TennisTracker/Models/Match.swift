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
    var player1Pic: String
    var player2Pic: String
    var player1DisplayName: String
    var player2DisplayName: String
    var player1Score: Int
    var player2Score: Int
    var winner: String
    var matchOngoing: Bool
    let setsToWin: Int
    let matchType: String
}
