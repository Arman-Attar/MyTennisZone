//
//  joinLeagueView.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-06-03.
//

import SwiftUI
import SDWebImageSwiftUI

struct joinLeagueView: View {
    @State var leagueName = ""
    @ObservedObject var leagueVm = LeagueViewModel()
    @State var showSheet = false
    @EnvironmentObject var vm: UserViewModel
    @State var notFoundAlert = false
    var body: some View {
        VStack{
            searchBar
            ScrollView {
                ForEach(0..<15){ num in
                    Divider().padding()
                }
            }
        }.navigationTitle("Join a League")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSheet) {
                LeagueSummaryView(leagueVM: leagueVm).environmentObject(vm)
            }
            .alert(isPresented: $notFoundAlert){
                Alert(title: Text("Error!"), message: Text("League Not Found"), dismissButton: .default(Text("Got it!")))
            }
    }
}

struct joinLeagueView_Previews: PreviewProvider {
    static var previews: some View {
        joinLeagueView().environmentObject(UserViewModel())
    }
}

extension joinLeagueView {
    
    private var searchBar: some View {
        HStack{
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search Leagues", text: $leagueName).foregroundColor(Color.black).disableAutocorrection(true)
            }.padding()
                .background(Color.gray).opacity(0.5)
                .cornerRadius(50)
                .padding(.leading)
            Button {
                let trimmedName = leagueName.trimmingCharacters(in: .whitespacesAndNewlines)
                Task {
                    await leagueVm.findLeague(leagueName: trimmedName.lowercased(), playerID: vm.user!.uid)
                    if leagueVm.league?.id ?? "" == ""{
                        notFoundAlert = true
                    }
                    else{
                        showSheet.toggle()
                    }
                }
                
            } label: {
                Text("Find")
                    .padding()
                    .foregroundColor(Color.black)
                    .font(.title3)
            }
        }
    }
}
