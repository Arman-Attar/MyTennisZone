//
//  homePage.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-08.
//

import SwiftUI

struct mainPage: View {
    @State var tabNumber = 0
    let tabImages = ["house", "person.3", "at" ,"crown", "person.circle"]
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack{
                switch tabNumber{
                case 0:
                    homePage()
                case 1:
                    leagueView()
                case 2:
                    addFriend()
                case 3:
                    tournyView()
                case 4:
                    profileTab()
                default:
                    Text("WHATEVER")
                }
                HStack{
                    ForEach(0..<5) { tab in
                        Button {
                            tabNumber = tab
                        } label: {
                            Spacer()
                            Image(systemName: tabImages[tab])
                                .font(.system(size: 25, weight: .semibold))
                                .foregroundColor(tabNumber == tab ? Color(.black) : Color.gray.opacity(0.8))
                            Spacer()
                        }
                    }.padding(.vertical)
                }.background(.ultraThinMaterial)
                    .frame(width: UIScreen.main.bounds.size.width)
            }
        }
    }
}

struct mainPage_Previews: PreviewProvider {
    static var previews: some View {
        mainPage()
    }
}
