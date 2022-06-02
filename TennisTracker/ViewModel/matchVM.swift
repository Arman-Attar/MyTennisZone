//
//  matchVM.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-26.
//

import Foundation
import SwiftUI
import FirebaseFirestoreSwift
import FirebaseFirestore
//import simd



class MatchViewModel: ObservableObject {
    @Published var currentMatch: Match?
    @Published var sets: [Set] = []
    
    
    
    func getMatchInfo(matchId: String){
        
    }
}
