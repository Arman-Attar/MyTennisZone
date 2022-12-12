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
