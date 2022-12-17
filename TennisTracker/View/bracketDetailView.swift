//
//  bracketDetailView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-07-31.
//

import SwiftUI
import SDWebImageSwiftUI

struct bracketDetailView: View {
    @State var selectedIndex = -1
    @ObservedObject var tournamentVm = TournamentViewModel()
    @ObservedObject var userVm = UserViewModel()
    let rounds = ["ROUND OF 32", "ROUND OF 16", "QUARTER-FINALS", "SEMI-FINALS", "FINAL", "WINNER"]
    @State private var modifyMatch = false
    @State private var matchInfo = false
    @State var settingTapped = false
    @State var confirmDeleteAlert = false
    @State var showSummaryPage = true
    @Environment(\.dismiss) var dismiss
    @State var refreshPage = false
    @State var i = 0
    @State var count = 0
    var body: some View {
        VStack {
            Spacer()
            ScrollView(.horizontal){
                if tournamentVm.firstRound == "R32" {
                    HStack{
                        ForEach(0..<6) { index in
                            Button {
                                selectedIndex = index
                            }label: {
                                Text(rounds[index])
                                    .font(.headline)
                                    .foregroundColor(selectedIndex == index ? Color.black : Color.gray)
                            }
                        }.padding(10)
                    }.padding()
                }
                else if tournamentVm.firstRound == "R16" {
                    HStack{
                        ForEach(1..<6) { index in
                            Button {
                                selectedIndex = index
                            } label: {
                                Text(rounds[index])
                                    .font(.headline)
                                    .foregroundColor(selectedIndex == index ? Color.black : Color.gray)
                            }
                        }.padding(10)
                    }.padding()
                }
                else if tournamentVm.firstRound == "QF" {
                    HStack{
                        ForEach(2..<6) { index in
                            Button {
                                selectedIndex = index
                            } label: {
                                Text(rounds[index])
                                    .font(.headline)
                                    .foregroundColor(selectedIndex == index ? Color.black : Color.gray)
                            }
                        }.padding(10)
                    }.padding()
                }
                else if tournamentVm.firstRound == "SEMI" {
                    HStack{
                        ForEach(3..<6) { index in
                            Button {
                                selectedIndex = index
                            } label: {
                                Text(rounds[index])
                                    .font(.headline)
                                    .foregroundColor(selectedIndex == index ? Color.black : Color.gray)
                            }
                        }.padding(10)
                    }.padding()
                }
                else {
                    HStack{
                        ForEach(4..<6) { index in
                            Button {
                                selectedIndex = index
                            } label: {
                                Text(rounds[index])
                                    .font(.headline)
                                    .foregroundColor(selectedIndex == index ? Color.black : Color.gray)
                            }
                        }.padding(10)
                    }.padding()
                }
            }
            Spacer()
            if tournamentVm.allMatchesFinished() && tournamentVm.playerList.count > 1{
                Button {
                    tournamentVm.endRound()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        selectedIndex = -1
                    }
                } label: {
                    HStack {
                        Text("End Current Round").font(.title3).padding()
                        Image(systemName: "flag.2.crossed").font(.title3).padding()
                    }.foregroundColor(Color.black)
                }
            }
            if selectedIndex == -1{
                VStack {
                    ScrollView(showsIndicators: false){
                    HStack {
                        Spacer()
                        Text("Tournament Board").font(.title3).fontWeight(.heavy)
                        Spacer()
                    }
                        Divider().padding()
                        VStack {
                            HStack{
                                Rectangle().frame(height: 1)
                                Text("Winner").font(.subheadline).fontWeight(.heavy).padding(.horizontal)
                                Rectangle().frame(height: 1)
                            }
                            VStack{
                                Spacer()
                                if tournamentVm.playerList.count > 1 {
                                    Image("profile")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 130, height: 130)
                                                .clipShape(Circle())
                                                .shadow(radius: 20)
                                    Text("To Be Determined").fontWeight(.heavy).padding()
                                }
                                else {
                                    if tournamentVm.tournament?.players[0].profilePicUrl ?? "profile" != "profile"{
                                    WebImage(url: URL(string: tournamentVm.tournament!.players[0].profilePicUrl))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                        .shadow(radius: 20)
                                        
                                        Text("\(tournamentVm.tournament!.players[0].displayName)").fontWeight(.heavy).padding()
                                    }
                                    else {
                                        Image("profile")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 130, height: 130)
                                                    .clipShape(Circle())
                                                    .shadow(radius: 20)
                                    }
                                }
                                Spacer()
                            }.padding(.top)
                        }
                        Divider().padding(.horizontal)
                    HStack{
                        VStack{
                            Text("\(tournamentVm.playersEntered.count)").font(.system(size: 70)).fontWeight(.black)
                            Text("PLAYERS ENTERED").font(.subheadline)
                        }
                        Divider().padding()
                        VStack{
                            Text("\(tournamentVm.playerList.count)").font(.system(size: 70)).fontWeight(.black)
                            Text("PLAYERS LEFT").font(.subheadline)
                        }
                    }.padding()
                    }.padding()
                }
            }
            else{
//            ScrollView{
//                if selectedIndex == 0 {
//                    matchContentField
//                }
//                else if selectedIndex == 1{
//                    matchContentField
//                }
//                else if selectedIndex == 2{
//                    matchContentField
//                }
//                else if selectedIndex == 3{
//                    matchContentField
//                }
//                else if selectedIndex == 4{
//                    matchContentField
//                }
//                else if selectedIndex == 5{
//                    winnerPage
//                }
//            }
            }
        }
        .sheet(isPresented: $modifyMatch) {
           // modifyMatchView(tournamentVm: tournamentVm ,isLeague: false)
        }
        .sheet(isPresented: $matchInfo) {
            //matchResultView(tournamentVm: tournamentVm, isLeague: false)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if tournamentVm.tournament?.admin ?? "" == userVm.user!.uid{
                    Button {
                        settingTapped.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing){
                Button {
                    //tournamentVm.refreshData(tournamentId: tournamentVm.tournament!.id)
                    selectedIndex = -1
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .confirmationDialog("Settings", isPresented: $settingTapped) {
            Button(role: .destructive) {
                confirmDeleteAlert.toggle()
            } label: {
                Text("Delete league")
            }
            
        }
        .alert(isPresented: $confirmDeleteAlert) {
            Alert(title: Text("Delete league"), message: Text("Are you sure you want to delete this league?"), primaryButton: .destructive(Text("Delete")){
                Task {
                    if await tournamentVm.deleteTournament(tournamentId: tournamentVm.tournament!.id!) {
                        await tournamentVm.getTournaments()
                        dismiss()
                    }
                }
            }, secondaryButton: .cancel())
        }
    }
}

struct bracketDetailView_Previews: PreviewProvider {
    static var previews: some View {
        bracketDetailView()
    }
}

extension bracketDetailView {
//    private var matchContentField: some View {
//        VStack{
//            ForEach(tournamentVm.listOfMatches, id: \.id) { match in
//                if selectedIndex == 0 && match.matchType == "R32"{
//                    Divider().padding(.horizontal)
//                    Button {
//                        tournamentVm.getCurrentMatch(matchId: match.id)
//                        if match.matchOngoing {
//                            modifyMatch.toggle()
//                        } else {
//                            matchInfo.toggle()
//                        }
//                    } label: {
//                        matchBubble(match: match)
//                    }.padding()
//                }
//                else if selectedIndex == 1 && match.matchType == "R16"{
//                    Divider().padding(.horizontal)
//                    Button {
//                        tournamentVm.getCurrentMatch(matchId: match.id)
//                        if match.matchOngoing {
//                            modifyMatch.toggle()
//                        } else {
//                            matchInfo.toggle()
//                        }
//                    } label: {
//                        matchBubble(match: match)
//                    }.padding()
//                }
//                else if selectedIndex == 2 && match.matchType == "QF"{
//                    Divider().padding(.horizontal)
//                    Button {
//                        tournamentVm.getCurrentMatch(matchId: match.id)
//                        if match.matchOngoing {
//                            modifyMatch.toggle()
//                        } else {
//                            matchInfo.toggle()
//                        }
//                    } label: {
//                        matchBubble(match: match)
//                    }.padding()
//                }
//
//                else if selectedIndex == 3 && match.matchType == "SEMI"{
//                    Divider().padding(.horizontal)
//                    Button {
//                        tournamentVm.getCurrentMatch(matchId: match.id)
//                        if match.matchOngoing {
//                            modifyMatch.toggle()
//                        } else {
//                            matchInfo.toggle()
//                        }
//                    } label: {
//                        matchBubble(match: match)
//                    }.padding()
//                }
//                else if selectedIndex == 4 && match.matchType == "FINAL"{
//                    Divider().padding(.horizontal)
//                    Button {
//                        tournamentVm.getCurrentMatch(matchId: match.id)
//                        if match.matchOngoing {
//                            modifyMatch.toggle()
//                        } else {
//                            matchInfo.toggle()
//                        }
//                    } label: {
//                        matchBubble(match: match)
//                    }.padding()
//                }
//            }
//        }
//    }
    
    struct matchBubble: View {
        @State var match: Match
        var body: some View {
            VStack {
                HStack {
                    Text("\(match.date)").foregroundColor(Color.black).font(.footnote)
                    Spacer()
                    if match.matchOngoing {
                        Text("Ongoing").font(.footnote).foregroundColor(Color.black)
                        Image(systemName: "circle.fill").foregroundColor(Color.green).font(.footnote)
                    }
                }.padding([.horizontal, .top])
                Divider().padding(.horizontal)
                HStack{
                    
                    WebImage(url: URL(string: match.player1Pic))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                    
                    Text("\(match.player1DisplayName)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    Spacer()
                    Text("\(match.player1Score)")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding()
                    
                }.padding(.horizontal)
                HStack{
                    
                    WebImage(url: URL(string: match.player2Pic))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                    
                    
                    Text("\(match.player2DisplayName)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    
                    Spacer()
                    Text("\(match.player2Score)")
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding()
                }.padding([.horizontal, .bottom])
            }
            .background(
                .regularMaterial,
                in: RoundedRectangle(cornerRadius: 10, style: .continuous)
            )
        }
    }
    
    private var winnerPage: some View {
        VStack(spacing: 10){
            if tournamentVm.tournament?.winner ?? "" != "" {
                HStack {
                    Image(systemName: "crown").font(.title3).padding()
                    Text("Champion")
                        .font(.title)
                        .fontWeight(.heavy)
                        .padding()
                    Image(systemName: "crown").font(.title3).padding()
                }.padding(.top, 20)
                HStack {
                    WebImage(url: URL(string: tournamentVm.tournament!.players[0].profilePicUrl))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .shadow(radius: 30)
                }.padding()
                HStack {
                    Spacer()
                    Text(tournamentVm.tournament!.players[0].displayName)
                        .font(.title)
                        .fontWeight(.heavy)
                        .padding()
                    Spacer()
                }
            }
            else {
                Spacer()
                HStack{
                    Spacer()
                    Text("Tournament Underway!")
                    Spacer()
                }
                Spacer()
            }
        }
    }
}
