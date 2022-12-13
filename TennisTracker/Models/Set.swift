//
//  Set.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-12.
//

import Foundation
import FirebaseFirestoreSwift

struct Set: Codable {
    @DocumentID var id: String?
    let matchId: String
    let winner: String
    let player1Uid: String
    let player2Uid: String
    let player1Points : Int
    let player2Points : Int
}
