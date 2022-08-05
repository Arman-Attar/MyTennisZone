//
//  bracketDetailView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-07-31.
//

import SwiftUI
import SDWebImageSwiftUI

struct bracketDetailView: View {
    @State var selectedIndex = 0
    @ObservedObject var tournamentVm = TournamentViewModel()
    let rounds = ["ROUND OF 32", "ROUND OF 16", "QUARTER-FINALS", "SEMI-FINALS", "FINAL"]
    var body: some View {
        VStack {
            Spacer()
            ScrollView(.horizontal){
                HStack{
                    ForEach(0..<5) { index in
                        Button {
                            selectedIndex = index
                        } label: {
                            Text(rounds[index])
                                .font(.headline)
                                .foregroundColor(selectedIndex == index ? Color.black : Color.gray)
                        }
                    }.padding(10)
                }
            }
            
            ScrollView{
                if selectedIndex == 0 {
                    ForEach(tournamentVm.listOfMatches, id: \.id) { match in
                        Button {
                            tournamentVm.getCurrentMatch(matchId: match.id)
                            if match.matchOngoing {
                                //modifyMatch.toggle()
                            } else {
                                //matchInfo.toggle()
                            }
                        } label: {
                            VStack {
                                HStack {
                                    Text("\(match.date)").foregroundColor(Color.black).font(.footnote)
                                    Spacer()
                                    if match.matchOngoing {
                                        Text("Ongoing").font(.footnote).foregroundColor(Color.black)
                                        Image(systemName: "circle.fill").foregroundColor(Color.green).font(.footnote)
                                    }
                                }.padding(.horizontal).padding(.top, 10)
                                HStack{
                                    Text("\(match.player1DisplayName)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                        .frame(width: UIScreen.main.bounds.size.width / 4)


                                    WebImage(url: URL(string: match.player1Pic))
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                        .shadow(radius: 20)
                                    
                                    Text("\(match.player1Score) - \(match.player2Score)")
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                        .padding(5)

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
                                        .frame(width: UIScreen.main.bounds.size.width / 4)


                                }.padding(.leading)
                                    .padding(.trailing)
                                    .padding(.bottom, 10)
                            }
                        }
                        Divider().padding(.horizontal)
                    }
                }
                else if selectedIndex == 1{
                    Text("SOMETHING")
                }
                else{
                ForEach(0..<9) { index in
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 350, height: 100)
                }.padding()
            }
            }
        }
    }
}

struct bracketDetailView_Previews: PreviewProvider {
    static var previews: some View {
        bracketDetailView()
    }
}
