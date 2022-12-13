//
//  DatabaseManager.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-07.
//

import Foundation
import Firebase
import UIKit
import FirebaseFirestoreSwift


class DatabaseManager {
    static let shared = DatabaseManager()
    private init () {}
    
    func getLeagues(userID: String) async throws -> [League] {
        var leagues: [League] = []
        let data = try await FirebaseManager.shared.firestore.collection("leagues").whereField("playerId", arrayContains: userID).getDocuments()
        for league in data.documents {
            do{
                leagues.append(try league.data(as: League.self))
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
                league = try document.data(as: League.self)
            }
        } catch {
            throw (error)
        }
        return league
    }
    
    func joinLeague(playerData: [String: Any], leagueID: String, playerID: String){
        FirebaseManager.shared.firestore.collection("leagues").document(leagueID).updateData(["players" : FieldValue.arrayUnion([playerData])])
        FirebaseManager.shared.firestore.collection("leagues").document(leagueID).updateData(["playerId" : FieldValue.arrayUnion([playerID])])
    }
    
    func deleteLeague(leagueID: String, bannerURL: String?) async throws -> Bool {
        do {
            if let bannerURL = bannerURL {
                let storageRef = FirebaseManager.shared.storage.reference(forURL: bannerURL)
                try await storageRef.delete()
                print("BANNER DELETED")
            }
            try await FirebaseManager.shared.firestore.collection("leagues").document(leagueID).delete()
            return true
        } catch  {
            throw error
        }
    }
    
    func createLeague(league: League) throws{
        do {
            try FirebaseManager.shared.firestore.collection("leagues").addDocument(from: league)
        } catch  {
            throw error
        }
    }
    
    func uploadBanner(image: UIImage) async throws -> String {
        let uid = UUID().uuidString
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return ""
        }
        do {
            try await ref.putDataAsync(imageData)
            return try await ref.downloadURL().absoluteString
        } catch {
            throw error
        }
    }
    
    func getSets(matchID: String) async throws -> [Set] {
        var sets: [Set] = []
        let data = try await FirebaseManager.shared.firestore.collection("sets").whereField("matchId", isEqualTo: matchID).getDocuments()
        for set in data.documents {
            do {
                sets.append(try set.data(as: Set.self))
            } catch {
                throw error
            }
        }
        return sets
    }
    
    func addSet(set: Set?, sets:[Set]?) throws {
        do {
            if let set = set {
                try FirebaseManager.shared.firestore.collection("sets").addDocument(from: set)
            } else if let sets = sets {
                for set in sets {
                   try FirebaseManager.shared.firestore.collection("sets").addDocument(from: set)
                }
            }
        } catch  {
            throw error
        }
    }
    
    func deleteSets(matchID: String) async throws {
        do {
            let setData = try await FirebaseManager.shared.firestore.collection("sets").whereField("matchId", isEqualTo: matchID).getDocuments()
            for set in setData.documents {
                try await set.reference.delete()
            }
        } catch {
            throw error
        }
    }
    
    func getMatches(leagueID: String) async throws -> [Match] {
        do {
            let league = try await FirebaseManager.shared.firestore.collection("leagues").document(leagueID).getDocument(as: League.self)
            return league.matches
        } catch {
            throw error
        }
    }
    
    func updateMatchList(matches: [Match], leagueID: String) async throws {
        do {
            try await FirebaseManager.shared.firestore.collection("leagues").document(leagueID).updateData(["matches" : FieldValue.delete()])
            for match in matches {
                let matchData = ["id" : match.id, "date" : match.date, "player1Pic" : match.player1Pic, "player2Pic" : match.player2Pic, "player1DisplayName" : match.player1DisplayName, "player2DisplayName" : match.player2DisplayName, "player1Score" : match.player1Score, "player2Score" : match.player2Score, "winner" : match.winner, "matchOngoing" : match.matchOngoing, "setsToWin" : match.setsToWin, "matchType" : match.matchType] as [String: Any]
                
                try await FirebaseManager.shared.firestore.collection("leagues").document(leagueID).updateData(["matches" : FieldValue.arrayUnion([matchData])])
            }
        } catch {
            throw error
        }
    }
    
    func getPlayers(leagueID: String) async throws -> [Player] {
        do {
            let league = try await FirebaseManager.shared.firestore.collection("leagues").document(leagueID).getDocument(as: League.self)
            return league.players
        } catch {
            throw error
        }
    }
    
    func updateDeletedStats(leagueID: String, winnerID: String, loserID: String, players: [Player]) async throws {
        do {
            try await FirebaseManager.shared.firestore.collection("leagues").document(leagueID).updateData(["players" : FieldValue.delete()])
            for player in players {
                let playerData = ["uid" : player.uid, "profilePicUrl" : player.profilePicUrl, "displayName" : player.displayName, "points" : player.points, "wins" : player.wins, "losses" : player.losses] as [String: Any]
                
               try await FirebaseManager.shared.firestore.collection("leagues").document(leagueID).updateData(["players" : FieldValue.arrayUnion([playerData])])
            }
            try? await FirebaseManager.shared.firestore.collection("users").document(winnerID).updateData(
                ["matchesPlayed" : FieldValue.increment(-1.00)])
            
            try? await FirebaseManager.shared.firestore.collection("users").document(winnerID).updateData(["matchesWon" : FieldValue.increment(-1.00)])
            
            try? await FirebaseManager.shared.firestore.collection("users").document(loserID).updateData(["matchesPlayed" : FieldValue.increment(-1.00)])
        } catch {
            throw error
        }
    }
    
    func updateStats(leagueID: String, winnerID: String, loserID: String, players: [Player]) async throws {
        do {
            try await FirebaseManager.shared.firestore.collection("leagues").document(leagueID).updateData(["players" : FieldValue.delete()])
            for player in players {
                let playerData = ["uid" : player.uid, "profilePicUrl" : player.profilePicUrl, "displayName" : player.displayName, "points" : player.points, "wins" : player.wins, "losses" : player.losses] as [String: Any]
                
                try await FirebaseManager.shared.firestore.collection("leagues").document(leagueID).updateData(["players" : FieldValue.arrayUnion([playerData])])
            }
                try await FirebaseManager.shared.firestore.collection("users").document(winnerID).updateData(
                    ["matchesPlayed" : FieldValue.increment(1.00)])
                
                try await FirebaseManager.shared.firestore.collection("users").document(winnerID).updateData(["matchesWon" : FieldValue.increment(1.00)])
                
                try await FirebaseManager.shared.firestore.collection("users").document(loserID).updateData(["matchesPlayed" : FieldValue.increment(1.00)])
        } catch {
            throw error
        }
    }
    
    func deleteMatch(leagueID: String, matchData: [String : Any]) async throws {
        do {
            try await FirebaseManager.shared.firestore.collection("leagues").document(leagueID).updateData(["matches" : FieldValue.arrayRemove([matchData])])
        } catch {
            throw error
        }
    }
    
    func createMatch(matchData: [String : Any], leagueID: String) async throws {
        do {
            try await  FirebaseManager.shared.firestore.collection("leagues").document(leagueID).updateData(["matches" : FieldValue.arrayUnion([matchData])])
        } catch {
            throw error
        }
    }
}
