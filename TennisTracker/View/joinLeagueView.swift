//
//  joinLeagueView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-06-03.
//

import SwiftUI

struct joinLeagueView: View {
    @State var leagueName = ""
    @ObservedObject var leagueVm = LeagueViewModel()
    @State var showSheet = false
    @ObservedObject var vm = UserViewModel()
    var body: some View {
        VStack{
            HStack{
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Search Leagues", text: $leagueName).foregroundColor(Color.black)
                }.padding()
                    .background(Color.gray).opacity(0.5)
                    .cornerRadius(50)
                    .padding(.leading)
                Button {
                    leagueVm.findLeague(leagueName: leagueName)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showSheet.toggle()
                    }
                } label: {
                    Text("Find")
                        .padding()
                        .foregroundColor(Color.black)
                        .font(.title3)
                }
            }
            ScrollView {
                ForEach(0..<15){ num in
                    Divider().padding()
                }
            }
        }.navigationTitle("Join a League")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSheet) {
                VStack {
                    Text(leagueVm.league?.name ?? "League Does Not Exist!")
                    
                    Button {
                        leagueVm.joinLeague(uid: vm.user!.uid, profilePic: vm.user!.profilePicUrl, displayName: vm.user!.displayName)
                    } label: {
                        Text("Join")
                    }

                }
            }
    }
}

struct joinLeagueView_Previews: PreviewProvider {
    static var previews: some View {
        joinLeagueView()
    }
}
