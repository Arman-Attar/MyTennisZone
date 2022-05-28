//
//  homePage.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-09.
//

import SwiftUI

struct homePage: View {
    let viewList = [AnyView(createLeague()), AnyView(signIn()), AnyView(signUp()), AnyView(mainPage())]
    let pictureList = ["c_league", "j_league", "c_tourny", "j_tourny"]
    let captionList = ["Create a League", "Join a League", "Create a Tournament", "Join a Tournament"]
    let iconList = ["pencil.circle.fill", "figure.wave.circle.fill", "pencil.circle.fill", "figure.wave.circle.fill"]
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false){
                VStack{
                    ForEach(0..<4) {index in
                        ZStack(alignment: .bottomTrailing) {
                            Image(pictureList[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.size.width - 20, height: UIScreen.main.bounds.size.height/5)
                                .cornerRadius(25)
                                .shadow(radius: 10)
                                .blur(radius: 1, opaque: false)
                            
                            HStack{
                                Text(captionList[index])
                                    .font(.title)
                                    .fontWeight(.heavy)
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 9)
                                    .padding()
                            }
                            NavigationLink(destination: viewList[index]){
                                RoundedRectangle(cornerRadius: 25)
                                    .frame(width: UIScreen.main.bounds.size.width - 20, height: UIScreen.main.bounds.size.height/5)
                                    .opacity(0.0)
                            }
                        }.frame(width: UIScreen.main.bounds.size.width - 20, height: UIScreen.main.bounds.size.height/5)
                            .padding(.vertical)
                    }
                }
            }.navigationTitle("Home")
        }
    }
}

struct homePage_Previews: PreviewProvider {
    static var previews: some View {
        homePage()
    }
}

