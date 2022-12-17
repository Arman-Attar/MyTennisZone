//
//  Tournament.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-12.
//

import Foundation
import FirebaseFirestoreSwift

struct Tournament: Codable {
    @DocumentID var id: String? 
    let name: String
    let playerId: [String]
    var players: [Player]
    let matches: [Match]
    let bannerURL: String?
    let admin: String
    let mode: String
    let winner: String?
}
