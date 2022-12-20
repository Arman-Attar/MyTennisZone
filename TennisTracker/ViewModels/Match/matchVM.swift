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
    @Published var playerList: [Player]
    @Published var admin: String
    
    private var listOfMatches: [Match] = []
    private var id: String
    private var matchID: String?
    @Published var player1: Player?
    @Published var player2: Player?
    
    init(id: String, listOfMatches: [Match], playerList: [Player], admin: String, matchID: String?) {
        self.id = id
        self.listOfMatches = listOfMatches
        self.playerList = playerList
        self.admin = admin
        if let matchID = matchID {
            self.matchID = matchID
        } else {
            self.finishedLoading = true
        }
    }
    
    func getCurrentMatch() async {
        let sets = await getSets()
        await MainActor.run(body: { [weak self] in
            self?.currentMatch = self?.listOfMatches.first(where: { $0.id == matchID!})
            self?.player1 = playerList.first(where: {$0.displayName == currentMatch?.player1DisplayName})
            self?.player2 = playerList.first(where: {$0.displayName == currentMatch?.player2DisplayName})
            self?.currentSets = sets
            self?.finishedLoading = true
        })
    }
    
    private func getSets() async -> [Set] {
        var sets: [Set] = []  
        do {
            sets = try await MatchDatabaseManager.shared.getSets(matchID: matchID!)
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
        
        let matchData = ["id" : matchID, "date" : date, "player1Pic" : player1.profilePicUrl, "player2Pic" : player2.profilePicUrl, "player1DisplayName" : player1.displayName, "player2DisplayName" : player2.displayName ,"player1Score" : player1Score, "player2Score" : player2Score, "winner" : winner, "matchOngoing" : matchOngoing, "setsToWin" : setsToWin, "matchType" : matchType] as [String: Any]
        do {
            try await MatchDatabaseManager.shared.createMatch(matchData: matchData, competitionID: self.id, competition: matchType)
            try MatchDatabaseManager.shared.addSet(set: nil, sets: sets)
            await updateMatch(ongoing: matchOngoing, player1DisplayName: player1.displayName, player2DisplayName: player2.displayName, matchID: matchID, matchType: matchType)
        } catch {
            print(error)
            return
        }
    }
    
    func updateMatch(ongoing: Bool, player1DisplayName: String, player2DisplayName: String, matchID: String, matchType: String) async -> String {
        let (player1Score, player2Score) = Utilities.calculatePlayerScores(sets: currentSets)
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
            var matches = try await MatchDatabaseManager.shared.getMatches(CompetitionID: self.id, competition: matchType)
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
            try await MatchDatabaseManager.shared.updateMatchList(matches: matches, CompetitionID: self.id, competition: matchType)
            if !ongoing {
                await updateStats(winner: winner, loser: loser, matchType: matchType)
                return loser
            } else {
                return ""
            }
        } catch  {
            print(error)
            return ""
        }
    }
    
    func updateStats(winner: String, loser: String, matchType: String) async {
        do {
            var players = try await MatchDatabaseManager.shared.getPlayers(competitionID: self.id, competition: matchType)
            let winnerIndex = players.firstIndex(where: { $0.displayName == winner})
            let loserIndex = players.firstIndex(where: { $0.displayName == loser})
            players[winnerIndex!].points += 3
            players[winnerIndex!].wins += 1
            players[loserIndex!].losses += 1
            let winnerObject = players.first(where: {$0.displayName == winner})
            let loserObject = players.first(where: {$0.displayName == loser})
            
            
            try await MatchDatabaseManager.shared.updateStats(competitionID: self.id, winnerID: winnerObject!.uid, loserID: loserObject!.uid, players: players, competition: matchType)
        } catch {
            print(error)
            return
        }
    }
    
    func deleteMatch() async {
        guard let currentMatch = self.currentMatch else { return }
        do {
            if !currentMatch.matchOngoing{
                var players = try await MatchDatabaseManager.shared.getPlayers(competitionID: self.id, competition: currentMatch.matchType)
                print("WE GOT PLAYERS")
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
                try await MatchDatabaseManager.shared.updateDeletedStats(competitionID: self.id, winnerID: players[winnerIndex!].uid, loserID: players[loserIndex!].uid, players: players, competition: currentMatch.matchType)
                try await MatchDatabaseManager.shared.deleteSets(matchID: currentMatch.id)
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
            
            try await MatchDatabaseManager.shared.deleteMatch(competition: currentMatch.matchType, competitionID: self.id, matchData: matchData)
        } catch {
            print(error)
            return
        }
    }
    func addSet(p1Points: Int, p2Points: Int, set: Set?) async {
        if let set = set {
            await MainActor.run(body: {
                self.currentSets.append(set)
            })
        } else {
            let setWinner = p1Points > p2Points ? player1!.uid : player2!.uid
            let setInfo = Set(matchId: currentMatch!.id, winner: setWinner, player1Uid: player1!.uid, player2Uid: player2!.uid, player1Points: p1Points, player2Points: p2Points)
            do {
                try MatchDatabaseManager.shared.addSet(set: setInfo, sets: nil)
                await MainActor.run(body: {
                    self.currentSets.append(setInfo)
                })
            } catch  {
                print(error)
            }
        }
    }
}
