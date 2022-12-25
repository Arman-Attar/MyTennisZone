//
//  BracketMatchUpsview.swift
//  MyTennisZone
//
//  Created by Arman Zadeh-Attar on 2022-12-24.
//

import SwiftUI

struct BracketMatchUpsview: View {
    let listOfMatches: [Match]
    let selectedIndex: Int
    
    @Binding var matchId: String
    @Binding var modifyMatch: Bool
    @Binding var matchInfo: Bool
    
    var body: some View {
       VStack {
           ForEach(listOfMatches, id: \.id) { match in
               if selectedIndex == 0 && match.matchType == "R32"{
                   Divider().padding(.horizontal)
                   Button {
                       self.matchId = match.id
                       if match.matchOngoing {
                           modifyMatch.toggle()
                       } else {
                           matchInfo.toggle()
                       }
                   } label: {
                       MatchBubble(match: match)
                   }.padding()
               }
               else if selectedIndex == 1 && match.matchType == "R16"{
                   Divider().padding(.horizontal)
                   Button {
                       self.matchId = match.id
                       if match.matchOngoing {
                           modifyMatch.toggle()
                       } else {
                           matchInfo.toggle()
                       }
                   } label: {
                       MatchBubble(match: match)
                   }.padding()
               }
               else if selectedIndex == 2 && match.matchType == "QF"{
                   Divider().padding(.horizontal)
                   Button {
                       self.matchId = match.id
                       if match.matchOngoing {
                           modifyMatch.toggle()
                       } else {
                           matchInfo.toggle()
                       }
                   } label: {
                       MatchBubble(match: match)
                   }.padding()
               }
               
               else if selectedIndex == 3 && match.matchType == "SEMI"{
                   Divider().padding(.horizontal)
                   Button {
                       self.matchId = match.id
                       if match.matchOngoing {
                           modifyMatch.toggle()
                       } else {
                           matchInfo.toggle()
                       }
                   } label: {
                       MatchBubble(match: match)
                   }.padding()
               }
               else if selectedIndex == 4 && match.matchType == "FINAL"{
                   Divider().padding(.horizontal)
                   Button {
                       self.matchId = match.id
                       if match.matchOngoing {
                           modifyMatch.toggle()
                       } else {
                           matchInfo.toggle()
                       }
                   } label: {
                       MatchBubble(match: match)
                   }.padding()
               }
           }
       }
    }
}

//struct BracketMatchUpsview_Previews: PreviewProvider {
//    static var previews: some View {
//        BracketMatchUpsview()
//    }
//}
