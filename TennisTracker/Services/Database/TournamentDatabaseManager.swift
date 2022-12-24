//
//  TournamentDatabaseManager.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-13.
//

import Foundation
import Firebase

actor TournamentDatabaseManager {
    static let shared = TournamentDatabaseManager()
    private init () {}
    
    func getTournaments(userID: String) async throws -> [Tournament] {
        var tournaments: [Tournament] = []
        let data = try await FirebaseManager.shared.firestore.collection("tournaments").whereField("playerId", arrayContains: userID).getDocuments()
        for tournament in data.documents {
            do{
                tournaments.append(try tournament.data(as: Tournament.self))
            }catch{
                throw(error)
            }
        }
        return tournaments
    }
    
    func getTournament(tournamentID: String) async throws -> Tournament {
        do {
            let tournament = try await FirebaseManager.shared.firestore.collection("tournaments").document(tournamentID).getDocument(as: Tournament.self)
            return tournament
        } catch {
            throw error
        }
    }
    
    func deleteTournament(tournamentID: String, bannerURL: String?) async throws -> Bool {
        do {
            if let bannerURL = bannerURL {
                let storageRef = FirebaseManager.shared.storage.reference(forURL: bannerURL)
                try await storageRef.delete()
            }
            try await FirebaseManager.shared.firestore.collection("tournaments").document(tournamentID).delete()
            return true
        } catch  {
            throw error
        }
    }
    
    func createTournament(tournament: Tournament) throws {
        do {
            _ = try FirebaseManager.shared.firestore.collection("tournaments").addDocument(from: tournament)
        } catch  {
            throw error
        }
    }
    
    func removePlayer(playerData: [String : Any], tournamentID: String) async throws {
        do {
            try await FirebaseManager.shared.firestore.collection("tournaments").document(tournamentID).updateData(["players" : FieldValue.arrayRemove([playerData])])
        } catch {
            throw error
        }
    }
    
    func tournamentWrapUp(winner: String, winnerID: String, tournamentID: String) async throws {
        do {
            try await FirebaseManager.shared.firestore.collection("tournaments").document(tournamentID).updateData(["winner" : winner])
            try await FirebaseManager.shared.firestore.collection("users").document(winnerID).updateData(["trophies" : FieldValue.increment(1.00)])
            
        } catch {
            throw error
        }
    }
    
}
