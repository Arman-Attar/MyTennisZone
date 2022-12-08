//
//  DatabaseManager.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-07.
//

import Foundation

class DatabaseManager {
    static let shared = DatabaseManager()
    private init () {}
    
    func getLeagues(userID: String) async throws -> [League] {
        var leagues: [League] = []
        let data = try await FirebaseManager.shared.firestore.collection("leagues").whereField("playerId", arrayContains: userID).getDocuments()
        for league in data.documents {
            do{
                let jsonData = try JSONSerialization.data(withJSONObject: league.data())
                leagues.append(try JSONDecoder().decode(League.self, from: jsonData))
            }catch{
                throw(error)
            }
        }
        return leagues
    }
    
    func getLeague(leagueID: String) async throws -> League {
        do {
            let league = try await FirebaseManager.shared.firestore.collection("leagues").document(leagueID).getDocument(as: League.self)
            return league
        } catch {
            throw error
        }
    }
    
    func searchLeague(leagueName: String) async throws -> League? {
        var league: League? = nil
        do {
            let data = try await FirebaseManager.shared.firestore.collection("leagues").whereField("name", isEqualTo: leagueName).getDocuments()
            if let document = data.documents.first {
                let jsonData = try JSONSerialization.data(withJSONObject: document.data())
                league = try JSONDecoder().decode(League.self, from: jsonData)
            }
        } catch {
            throw (error)
        }
        return league
    }
}
