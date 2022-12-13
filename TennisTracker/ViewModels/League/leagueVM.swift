//
//  leagueVM.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-19.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class LeagueViewModel: ObservableObject {
    @Published var leagues: [League]?
    @Published var league: League?
    @Published var playerList: [Player] = []
    @State var topPlayer = ""
    @Published var listOfMatches: [Match] = []
    @Published var currentMatch: Match?
    @Published var currentSets: [Set] = []
    @Published var playerImages: [UIImage?] = []
    @Published var leagueLoaded = false
    @Published var playerIsJoined = false
    
    // REFACTORED
    
    func getLeagues() async{
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        do {
            let leagues = try await DatabaseManager.shared.getLeagues(userID: uid)
            await MainActor.run(body: {
                self.leagues = leagues
            })
        } catch {
            print(error)
        }
    }
    func getCurrentLeague(leagueId: String) async {
        do {
            let league = try await DatabaseManager.shared.getLeague(leagueID: leagueId)
            await MainActor.run(body: { [weak self] in
                playerList.removeAll()
                self?.league = league
                var players = league.players
                players.sort {
                    $0.points > $1.points
                }
                self?.playerList = players
                self?.listOfMatches = league.matches.reversed()
            })
        } catch {
            print(error)
        }
    }
    func loadImages() async{
        do {
            let images = try await ImageLoader.shared.getImages(playerList: self.playerList)
            await MainActor.run(body: {
                self.playerImages = images
                self.leagueLoaded = true
            })
        } catch {
            print(error)
        }
    }
    func findLeague(leagueName: String, playerID: String) async {
        await MainActor.run(body: {
            self.league = nil
        })
        do {
            if let league = try await DatabaseManager.shared.searchLeague(leagueName: leagueName) {
                await MainActor.run(body: { [weak self] in
                    self?.league = league
                    self?.playerList = league.players
                })
            }
        } catch {
            print(error)
            await MainActor.run(body: {
                self.league = nil
                
            })
        }
        let userStatus = await isUserJoined(playerID: playerID)
        await MainActor.run(body: {
            self.playerIsJoined = userStatus
        })
    }
    func isUserJoined(playerID: String) async -> Bool {
        let result = self.playerList.filter{playerID == $0.uid}
        return !result.isEmpty
    }
    func joinLeague(uid: String, profilePic: String, displayName: String){
        let playerData = ["uid": uid, "profilePicUrl": profilePic, "displayName": displayName, "points": 0, "wins": 0, "losses": 0] as [String: Any]
        if let currentLeague = league,
           let leagueID = currentLeague.id {
            DatabaseManager.shared.joinLeague(playerData: playerData, leagueID: leagueID, playerID: uid)
        }
    }
    func deleteLeague(leagueID: String) async -> Bool {
        var deleted = false
        if let league = self.league {
            do {
                if league.bannerURL != "" {
                    try await deleted = DatabaseManager.shared.deleteLeague(leagueID: leagueID, bannerURL: league.bannerURL)
                } else {
                    try await deleted = DatabaseManager.shared.deleteLeague(leagueID: leagueID, bannerURL: nil)
                }
            } catch {
                print(error)
            }
            
        }
        return deleted
    }
    func createLeague(leagueName: String, playerId: [String], admin: String, players: [Player], bannerImage: UIImage?) async -> Bool {
        do {
            var bannerURL = ""
            if let bannerImage = bannerImage {
                bannerURL = try await DatabaseManager.shared.uploadBanner(image: bannerImage)
            }
            let leagueData = League(name: leagueName.lowercased(), playerId: playerId, players: players, matches: [], bannerURL: bannerURL, admin: admin)
            try DatabaseManager.shared.createLeague(league: leagueData)
            return true
        } catch  {
            print(error)
            return false
        }
    }
    func getCurrentMatch(matchId: String) async {
        await MainActor.run(body: {
            self.currentSets = []
        })
        for match in listOfMatches {
            if match.id == matchId{
                await MainActor.run(body: {
                    self.currentMatch = match
                })
            }
        }
        do {
            let setData = try await DatabaseManager.shared.getSets(matchID: matchId)
            await MainActor.run(body: {
                self.currentSets = setData
            })
        } catch {
            print(error)
        }
    }
    func addSet(p1Points: Int, p2Points: Int) async {
        var p1Uid = ""
        var p2Uid = ""
        for player in league!.players {
            if player.displayName == currentMatch!.player1DisplayName{
                p1Uid = player.uid
            }
            else if player.displayName == currentMatch!.player2DisplayName {
                p2Uid = player.uid
            }
        }
        
        let setWinner = p1Points > p2Points ? p1Uid : p2Uid
        
        let setInfo = Set(matchId: currentMatch!.id, winner: setWinner, player1Uid: p1Uid, player2Uid: p2Uid, player1Points: p1Points, player2Points: p2Points)
        do {
            try DatabaseManager.shared.addSet(set: setInfo)
            await MainActor.run(body: {
                self.currentSets.append(setInfo)
            })
        } catch  {
            print(error)
        }
    }
    
    //MUST BE TESTED
    func updateMatch(ongoing: Bool) async {
        let (player1Score, player2Score) = calculatePlayerScores()
        var winner = ""
        if !ongoing {
            if player1Score > player2Score {
                winner = currentMatch!.player1DisplayName
            }
            else{
                winner = currentMatch!.player2DisplayName
            }
        }
        guard let leagueID = league?.id else { return }
        do {
            var matches = try await DatabaseManager.shared.getMatches(leagueID: leagueID)
            var matchIndex = -1
            for match in matches {
                matchIndex += 1
                if match.id == self.currentMatch!.id{
                    break
                }
            }
            matches[matchIndex].player1Score = player1Score
            matches[matchIndex].player2Score = player2Score
            matches[matchIndex].matchOngoing = ongoing
            matches[matchIndex].winner = winner
            
            try await DatabaseManager.shared.updateMatchList(matches: matches, leagueID: leagueID)
        } catch  {
            print(error)
            return
        }
        
    }
    func deleteMatch() async {
        guard let leagueID = league?.id else { return }
        do {
            if !currentMatch!.matchOngoing{
                var players = try await DatabaseManager.shared.getPlayers(leagueID: leagueID)
                let winnerIndex = players.firstIndex(where: { $0.displayName == self.currentMatch!.winner})
                var loser = ""
                if self.currentMatch!.player1DisplayName == self.currentMatch!.winner {
                    loser = self.currentMatch!.player2DisplayName
                }
                else {
                    loser = self.currentMatch!.player1DisplayName
                }
                let loserIndex = players.firstIndex(where: { $0.displayName == loser})
                players[winnerIndex!].points -= 3
                players[winnerIndex!].wins -= 1
                players[loserIndex!].losses -= 1
                
                try await DatabaseManager.shared.updateDeletedStats(leagueID: leagueID, winnerID: players[winnerIndex!].uid, loserID: players[loserIndex!].uid, players: players)
                try await DatabaseManager.shared.deleteSets(matchID: currentMatch!.id)
            }
            
            let matchData: [String: Any] = [
                "id" : self.currentMatch!.id as Any,
                "date" : self.currentMatch!.date,
                "player1Pic" : self.currentMatch!.player1Pic,
                "player2Pic" : self.currentMatch!.player2Pic,
                "player1DisplayName" : self.currentMatch!.player1DisplayName,
                "player2DisplayName" : self.currentMatch!.player2DisplayName,
                "player1Score" : self.currentMatch!.player1Score,
                "player2Score" : self.currentMatch!.player2Score,
                "winner" : self.currentMatch!.winner,
                "matchOngoing" : self.currentMatch!.matchOngoing,
                "setsToWin" : self.currentMatch!.setsToWin,
                "matchType" : self.currentMatch!.matchType
            ]
            
            try await DatabaseManager.shared.deleteMatch(leagueID: leagueID, matchData: matchData)
            
        } catch {
            print(error)
            return
        }
    }
    
    // UTILITY FUNCTIONS
    func getPos(players: [Player], uid: String) -> Int {
        var pos: Int = 0
        for player in players {
            pos += 1
            if player.uid == uid {
                break
            }
        }
        return pos
    }
    private func calculatePlayerScores() -> (Int, Int) {
        var player1Score = 0
        var player2Score = 0
        for set in self.currentSets {
            if set.player1Points > set.player2Points {
                player1Score += 1
            }
            else{
                player2Score += 1
            }
        }
        return (player1Score, player2Score)
    }
}
