//
//  tournyView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-11.
//

import SwiftUI

struct tournyView: View {
    let leagueNames = ["Arman & Peter", "Andrew & Arman", "Andrew & Peter"]
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false){
                VStack{
                    ForEach(0..<3){ index in
                        VStack{
                            Image("tourny")
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.size.width - 50, height: UIScreen.main.bounds.size.height / 4)
                                .padding(.horizontal)
                            HStack {
                                Text(leagueNames[index])
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                                Image(systemName: "person.fill")
                                    .foregroundColor(.gray)
                                Text("2")
                                Rectangle().frame(width: 1, height: 20)
                                Text("Position:")
                                Text("1st")
                            }
                            .padding(.vertical)
                            .frame(width: UIScreen.main.bounds.size.width - 50)
                            Divider().padding(.horizontal)
                        }
                        .frame(width: UIScreen.main.bounds.size.width - 80, height: UIScreen.main.bounds.size.height / 3)
                        .padding()
                        .shadow(radius: 20)
                    }
                }
            }.navigationTitle("Tournaments")
        }
    }
}

struct tournyView_Previews: PreviewProvider {
    static var previews: some View {
        tournyView()
    }
}
