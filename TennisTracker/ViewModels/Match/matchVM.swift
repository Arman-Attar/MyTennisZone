//
//  matchVM.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-13.
//

import Foundation

class MatchViewModel: ObservableObject {
    @Published var currentMatch: Match?
    @Published var currentSets: [Set] = []
    @Published var finishedLoading = false
    
    private var listOfMatches: [Match] = []
    private var id: String
    private var player1: Player?
    private var player2: Player?
    
    init (id: String, listOfMatches: [Match], player1: Player?, player2: Player?) {
        self.id = id
        self.listOfMatches = listOfMatches
        if let player1 = player1, let player2 = player2 {
            self.player1 = player1
            self.player2 = player2
        }
    }
    
    func getCurrentMatch(matchID: String) async {
        let sets = await getSets(matchID: matchID)
        await MainActor.run(body: {
            self.currentMatch = self.listOfMatches.first(where: { $0.id == matchID})
            self.currentSets = sets
            self.finishedLoading = true
        })
    }
    
    private func getSets(matchID: String) async -> [Set] {
        var sets: [Set] = []
        do {
            sets = try await DatabaseManager.shared.getSets(matchID: matchID)
        } catch {
            print(error)
        }
        return sets
    }
    
    func createMatch(matchOngoing: Bool, player1: Player, player2: Player, date: Date, setsToWin: Int, matchType: String, sets: [Set], matchID: String) async {
        let (player1Score, player2Score) = Utilities.calculatePlayerScores(sets: sets)
        var winner = ""
        if !matchOngoing{
            if player1Score > player2Score {
                winner = player1.displayName
            }
            else {
                winner = player2.displayName
            }
        }
        let date = Utilities.convertDateToString(date: date)
        
        let matchData = ["id" : matchID, "date" : date, "player1Pic" : player1.profilePicUrl, "player2Pic" : player2.profilePicUrl, "player1DisplayName" : player1.displayName, "player2DisplayName" : player2.displayName ,"player1Score" : player1Score, "player2Score" : player2Score, "winner" : winner, "matchOngoing" : matchOngoing, "setsToWin" : setsToWin, "matchType" : "League"] as [String: Any]
        
        do {
            try await DatabaseManager.shared.createMatch(matchData: matchData, leagueID: self.id)
            try DatabaseManager.shared.addSet(set: nil, sets: sets)
            await updateMatch(ongoing: matchOngoing, sets: sets, player1DisplayName: player1.displayName, player2DisplayName: player2.displayName, matchID: matchID)
        } catch {
            print(error)
            return
        }
    }
    
    func updateMatch(ongoing: Bool, sets: [Set], player1DisplayName: String, player2DisplayName: String, matchID: String) async {
        let (player1Score, player2Score) = Utilities.calculatePlayerScores(sets: sets)
        var winner = ""
        var loser = ""
        if !ongoing {
            if player1Score > player2Score {
                winner = player1DisplayName
                loser = player2DisplayName
            }
            else{
                winner = player2DisplayName
                loser = player1DisplayName
            }
        }
        do {
            var matches = try await DatabaseManager.shared.getMatches(leagueID: self.id)
            var matchIndex = -1
            for match in matches {
                matchIndex += 1
                if match.id == matchID{
                    break
                }
            }
            matches[matchIndex].player1Score = player1Score
            matches[matchIndex].player2Score = player2Score
            matches[matchIndex].matchOngoing = ongoing
            matches[matchIndex].winner = winner
            
            try await DatabaseManager.shared.updateMatchList(matches: matches, leagueID: self.id)
            if !ongoing {
                await updateStats(winner: winner, loser: loser)
            }
        } catch  {
            print(error)
            return
        }
    }
    
    func updateStats(winner: String, loser: String) async {
        do {
            var players = try await DatabaseManager.shared.getPlayers(leagueID: self.id)
            let winnerIndex = players.firstIndex(where: { $0.displayName == winner})
            let loserIndex = players.firstIndex(where: { $0.displayName == loser})
            players[winnerIndex!].points += 3
            players[winnerIndex!].wins += 1
            players[loserIndex!].losses += 1
            
            try await DatabaseManager.shared.updateStats(leagueID: self.id, winnerID: winner, loserID: loser, players: players)
        } catch {
            print(error)
            return
        }
    }
    
    func deleteMatch() async {
        guard let currentMatch = self.currentMatch else { return }
        do {
            if currentMatch.matchOngoing{
                var players = try await DatabaseManager.shared.getPlayers(leagueID: self.id)
                let winnerIndex = players.firstIndex(where: { $0.displayName == currentMatch.winner})
                var loser = ""
                if self.currentMatch!.player1DisplayName == currentMatch.winner {
                    loser = currentMatch.player2DisplayName
                }
                else {
                    loser = currentMatch.player1DisplayName
                }
                let loserIndex = players.firstIndex(where: { $0.displayName == loser})
                players[winnerIndex!].points -= 3
                players[winnerIndex!].wins -= 1
                players[loserIndex!].losses -= 1
                
                try await DatabaseManager.shared.updateDeletedStats(leagueID: self.id, winnerID: players[winnerIndex!].uid, loserID: players[loserIndex!].uid, players: players)
                try await DatabaseManager.shared.deleteSets(matchID: currentMatch.id)
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
            
            try await DatabaseManager.shared.deleteMatch(leagueID: self.id, matchData: matchData)
        } catch {
            print(error)
            return
        }
    }
    func addSet(p1Points: Int, p2Points: Int) async {
//        var p1Uid = ""
//        var p2Uid = ""
//        for player in league!.players {
//            if player.displayName == currentMatch!.player1DisplayName{
//                p1Uid = player.uid
//            }
//            else if player.displayName == currentMatch!.player2DisplayName {
//                p2Uid = player.uid
//            }
//        }
        
        let setWinner = p1Points > p2Points ? player1!.uid : player2!.uid
        
        let setInfo = Set(matchId: currentMatch!.id, winner: setWinner, player1Uid: player1!.uid, player2Uid: player2!.uid, player1Points: p1Points, player2Points: p2Points)
        do {
            try DatabaseManager.shared.addSet(set: setInfo, sets: nil)
            await MainActor.run(body: {
                self.currentSets.append(setInfo)
            })
        } catch  {
            print(error)
        }
    }
}
