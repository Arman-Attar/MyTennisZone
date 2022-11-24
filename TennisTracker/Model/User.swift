//
//  User.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-02.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable {    
    let uid: String
    let email: String
    let username: String
    let profilePicUrl: String
    var displayName: String
    let matchesPlayed: Int
    let matchesWon: Int
    let trophies: Int
    let friends: [String]
}

struct League: Codable {
    let id: String
    let name: String
    let playerId: [String]
    var players: [Player]
    let matches: [Match]
    let bannerURL: String?
    let admin: String
}

struct Friend: Codable {
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

struct Set: Codable {
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
    //var played: Int
}

struct Tournament: Codable {
    let id: String
    let name: String
    let playerId: [String]
    var players: [Player]
    let matches: [Match]
    let bannerURL: String?
    let admin: String
    let mode: String
    let winner: String?
}

