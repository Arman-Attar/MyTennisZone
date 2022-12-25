//
//  MatchHistoryView.swift
//  MyTennisZone
//
//  Created by Arman Zadeh-Attar on 2022-12-24.
//

import SwiftUI
import SDWebImageSwiftUI

struct MatchHistoryView: View {
    
    let listOfMatches: [Match]
    @Binding var matchId: String
    @Binding var modifyMatch: Bool
    @Binding var matchInfo: Bool
    
    var body: some View {
        ScrollView{
            VStack {
                ForEach(listOfMatches, id: \.id) { match in
                    Button {
                            matchId = match.id
                            if match.matchOngoing {
                                modifyMatch.toggle()
                            } else {
                                matchInfo.toggle()
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
                                    .frame(width: UIScreen.main.bounds.size.width / 4.5)
                                    .fixedSize(horizontal: false, vertical: true)

                                if match.player1Pic != "" {
                                    WebImage(url: URL(string: match.player1Pic))
                                        .userImageModifier(width: 40, height: 40)
                                } else {
                                    Image("profile")
                                        .userImageModifier(width: 40, height: 40)
                                }
                                
                                Text("\(match.player1Score) - \(match.player2Score)")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .padding(5)

                                if match.player2Pic != "" {
                                    WebImage(url: URL(string: match.player2Pic))
                                        .userImageModifier(width: 40, height: 40)
                                } else {
                                    Image("profile")
                                        .userImageModifier(width: 40, height: 40)
                                }

                                Text("\(match.player2DisplayName)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .frame(width: UIScreen.main.bounds.size.width / 4.5)
                                    .fixedSize(horizontal: false, vertical: true)


                            }.padding(.leading)
                                .padding(.trailing)
                                .padding(.bottom, 10)
                        }
                    }
                    Divider().padding(.horizontal)
                }
            }
        }
    }
}

//struct MatchHistoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        MatchHistoryView(listOfMatches: [])
//    }
//}
