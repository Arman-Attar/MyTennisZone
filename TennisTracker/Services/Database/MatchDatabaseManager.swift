//
//  MatchDatabaseManager.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-16.
//

import Foundation
import Firebase

actor MatchDatabaseManager {
    static let shared = MatchDatabaseManager()
    private init () {}
    
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
                _ = try FirebaseManager.shared.firestore.collection("sets").addDocument(from: set)
            } else if let sets = sets {
                for set in sets {
                    _ = try FirebaseManager.shared.firestore.collection("sets").addDocument(from: set)
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
    
    func getMatches(CompetitionID: String, competition: String) async throws -> [Match] {
        do {
            if competition == "league" {
                let league = try await FirebaseManager.shared.firestore.collection("leagues").document(CompetitionID).getDocument(as: League.self)
                return league.matches
            } else {
                let tournament = try await FirebaseManager.shared.firestore.collection("tournaments").document(CompetitionID).getDocument(as: Tournament.self)
                return tournament.matches
            }
        } catch {
            throw error
        }
    }
    
    func updateMatchList(matches: [Match], CompetitionID: String, competition: String) async throws {
        do {
            if competition == "league" {
                try await FirebaseManager.shared.firestore.collection("leagues").document(CompetitionID).updateData(["matches" : FieldValue.delete()])
                for match in matches {
                    let matchData = ["id" : match.id, "date" : match.date, "player1Pic" : match.player1Pic, "player2Pic" : match.player2Pic, "player1DisplayName" : match.player1DisplayName, "player2DisplayName" : match.player2DisplayName, "player1Score" : match.player1Score, "player2Score" : match.player2Score, "winner" : match.winner, "matchOngoing" : match.matchOngoing, "setsToWin" : match.setsToWin, "matchType" : match.matchType] as [String: Any]
                    
                    try await FirebaseManager.shared.firestore.collection("leagues").document(CompetitionID).updateData(["matches" : FieldValue.arrayUnion([matchData])])
                }
            } else {
                try await FirebaseManager.shared.firestore.collection("tournaments").document(CompetitionID).updateData(["matches" : FieldValue.delete()])
                for match in matches {
                    let matchData = ["id" : match.id, "date" : match.date, "player1Pic" : match.player1Pic, "player2Pic" : match.player2Pic, "player1DisplayName" : match.player1DisplayName, "player2DisplayName" : match.player2DisplayName, "player1Score" : match.player1Score, "player2Score" : match.player2Score, "winner" : match.winner, "matchOngoing" : match.matchOngoing, "setsToWin" : match.setsToWin, "matchType" : match.matchType] as [String: Any]
                    
                    try await FirebaseManager.shared.firestore.collection("tournaments").document(CompetitionID).updateData(["matches" : FieldValue.arrayUnion([matchData])])
                }
            }
        } catch {
            throw error
        }
    }
    
    func deleteMatch(competition: String, competitionID: String, matchData: [String : Any]) async throws {
        do {
            if competition == "league" {
                try await FirebaseManager.shared.firestore.collection("leagues").document(competitionID).updateData(["matches" : FieldValue.arrayRemove([matchData])])
            } else {
                try await FirebaseManager.shared.firestore.collection("tournaments").document(competitionID).updateData(["matches" : FieldValue.arrayRemove([matchData])])
            }
        } catch {
            throw error
        }
    }
    
    func createMatch(matchData: [String : Any], competitionID: String, competition: String) async throws {
        do {
            if competition == "league" {
                try await  FirebaseManager.shared.firestore.collection("leagues").document(competitionID).updateData(["matches" : FieldValue.arrayUnion([matchData])])
            } else {
                try await  FirebaseManager.shared.firestore.collection("tournaments").document(competitionID).updateData(["matches" : FieldValue.arrayUnion([matchData])])
            }
        } catch {
            throw error
        }
    }
    
    func updateDeletedStats(competitionID: String, winnerID: String, loserID: String, players: [Player], competition: String) async throws {
        do {
            if competition == "league" {
                try await FirebaseManager.shared.firestore.collection("leagues").document(competitionID).updateData(["players" : FieldValue.delete()])
                for player in players {
                    let playerData = ["uid" : player.uid, "profilePicUrl" : player.profilePicUrl, "displayName" : player.displayName, "points" : player.points, "wins" : player.wins, "losses" : player.losses] as [String: Any]
                    
                    try await FirebaseManager.shared.firestore.collection("leagues").document(competitionID).updateData(["players" : FieldValue.arrayUnion([playerData])])
                }
            } else {
                try await FirebaseManager.shared.firestore.collection("tournaments").document(competitionID).updateData(["players" : FieldValue.delete()])
                for player in players {
                    let playerData = ["uid" : player.uid, "profilePicUrl" : player.profilePicUrl, "displayName" : player.displayName, "points" : player.points, "wins" : player.wins, "losses" : player.losses] as [String: Any]
                    
                    try await FirebaseManager.shared.firestore.collection("tournaments").document(competitionID).updateData(["players" : FieldValue.arrayUnion([playerData])])
                }
            }
        } catch {
            throw error
        }
        if winnerID != "" {
            try? await FirebaseManager.shared.firestore.collection("users").document(winnerID).updateData(
                ["matchesPlayed" : FieldValue.increment(-1.00)])
            
            try? await FirebaseManager.shared.firestore.collection("users").document(winnerID).updateData(["matchesWon" : FieldValue.increment(-1.00)])
        }
        if loserID != "" {
            try? await FirebaseManager.shared.firestore.collection("users").document(loserID).updateData(["matchesPlayed" : FieldValue.increment(-1.00)])
        }
    }
    
    func updateStats(competitionID: String, winnerID: String, loserID: String, players: [Player], competition: String) async throws {
        do {
            if competition == "league" {
                try await FirebaseManager.shared.firestore.collection("leagues").document(competitionID).updateData(["players" : FieldValue.delete()])
                for player in players {
                    let playerData = ["uid" : player.uid, "profilePicUrl" : player.profilePicUrl, "displayName" : player.displayName, "points" : player.points, "wins" : player.wins, "losses" : player.losses] as [String: Any]
                    
                    try await FirebaseManager.shared.firestore.collection("leagues").document(competitionID).updateData(["players" : FieldValue.arrayUnion([playerData])])
                }
            } else {
                try await FirebaseManager.shared.firestore.collection("tournaments").document(competitionID).updateData(["players" : FieldValue.delete()])
                for player in players {
                    let playerData = ["uid" : player.uid, "profilePicUrl" : player.profilePicUrl, "displayName" : player.displayName, "points" : player.points, "wins" : player.wins, "losses" : player.losses] as [String: Any]
                    
                    try await FirebaseManager.shared.firestore.collection("tournaments").document(competitionID).updateData(["players" : FieldValue.arrayUnion([playerData])])
                }
            }
            try? await FirebaseManager.shared.firestore.collection("users").document(winnerID).updateData(
                ["matchesPlayed" : FieldValue.increment(1.00)])
            
            try? await FirebaseManager.shared.firestore.collection("users").document(winnerID).updateData(["matchesWon" : FieldValue.increment(1.00)])
            
            try? await FirebaseManager.shared.firestore.collection("users").document(loserID).updateData(["matchesPlayed" : FieldValue.increment(1.00)])
        } catch {
            throw error
        }
    }
    
    func getPlayers(competitionID: String, competition: String) async throws -> [Player] {
        do {
            if competition == "league" {
                let league = try await FirebaseManager.shared.firestore.collection("leagues").document(competitionID).getDocument(as: League.self)
                return league.players
            } else {
                let tournament = try await FirebaseManager.shared.firestore.collection("tournaments").document(competitionID).getDocument(as: Tournament.self)
                return tournament.players
            }
        } catch {
            throw error
        }
    }
}
