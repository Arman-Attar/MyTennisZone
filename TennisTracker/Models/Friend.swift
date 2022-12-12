//
//  Friend.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-12.
//

import Foundation

struct Friend: Codable {
    let uid: String
    let username: String
    let profilePicUrl: String
    let displayName: String
    let matchesPlayed: Int
    let matchesWon: Int
    let trophies: Int
}
