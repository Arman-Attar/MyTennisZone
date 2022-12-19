//
//  Player.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-12.
//

import Foundation

struct Player: Codable{
    let uid: String
    var profilePicUrl: String
    let displayName: String
    var points: Int
    var wins: Int
    var losses: Int
}
