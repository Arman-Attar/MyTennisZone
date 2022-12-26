//
//  MatchBubble.swift
//  MyTennisZone
//
//  Created by Arman Zadeh-Attar on 2022-12-23.
//

import SwiftUI
import SDWebImageSwiftUI

struct MatchBubble: View {
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
                if match.player1Pic != "" {
                    WebImage(url: URL(string: match.player1Pic))
                        .userImageModifier(width: 50, height: 50)
                        .padding()
                } else {
                    Image("profile")
                        .userImageModifier(width: 50, height: 50)
                        .padding()
                }
                
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
                
                if match.player2Pic != "" {
                    WebImage(url: URL(string: match.player2Pic))
                        .userImageModifier(width: 50, height: 50)
                        .padding()
                } else {
                    Image("profile")
                        .userImageModifier(width: 50, height: 50)
                        .padding()
                }
                
                if match.player2DisplayName == "" {
                    Text("(Bye)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                } else {
                    Text("\(match.player2DisplayName)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }
                
                
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

//struct MatchBubble_Previews: PreviewProvider {
//    static var previews: some View {
//        MatchBubble()
//    }
//}
