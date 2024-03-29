//
//  League.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-12.
//

import Foundation
import FirebaseFirestoreSwift

struct League: Codable {
    @DocumentID var id: String?
    let name: String
    let playerId: [String]
    var players: [Player]
    var matches: [Match]
    let bannerURL: String
    let admin: String
}
