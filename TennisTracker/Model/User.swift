//
//  User.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-02.
//

import Foundation
import FirebaseFirestoreSwift

struct User {
    let uid: String
    let email: String
    let username: String
    let profilePicUrl: String
    let displayName: String
    let matchesPlayed: Int
    let matchesWon: Int
    let trophies: Int
    let friendsUid: [String]
}

struct League: Codable {
    let id: String
    let name: String
    let playerId: [String]
    var players: [Player]
    let matches: [Match]
}

struct Friend {
    let uid: String
    let username: String
    let profilePicUrl: String
    let displayName: String
    let matchesPlayed: Int
    let matchesWon: Int
    let trophies: Int
}

struct Match: Codable {
    let id: String
    let date: Date
    let player1Pic: String
    let player2Pic: String
    let player1DisplayName: String
    let player2DisplayName: String
    let player1Score: Int
    let player2Score: Int
    let winner: String
    let loser: String
    let matchFinished: Bool
    let setsToWin: Int
}

struct Set {
    let setId: String
    let matchId: String
    let winner: String
    let player1Uid: String
    let player2Uid: String
    let player1Points : Int
    let player2Points : Int
}

struct Player: Codable{
    let uid: String
    let profilePicUrl: String
    let displayName: String
    var points: Int
    var wins: Int
    var losses: Int
}

