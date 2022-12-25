//
//  addFriend.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-15.
//

import SwiftUI
import SDWebImageSwiftUI

struct addFriend: View {
    @EnvironmentObject private var vm: UserViewModel
    @State var userName = ""
    @State var showSearchBar = false
    @State var userNotFound = false
    var body: some View {
        VStack{
            searchBar
            ScrollView {
                ForEach(0..<15){ num in
                    Divider().padding()
                }
            }
        }.sheet(isPresented: $showSearchBar) {
            if let user = vm.searchedUser {
                UserSummaryView(isFriend: vm.isFriend, user: user).environmentObject(vm)
            }
        }
            .alert(isPresented: $userNotFound){
                Alert(title: Text("Error!"), message: Text("User Not Found"), dismissButton: .default(Text("Got it!")))
            }
    }
}

struct addFriend_Previews: PreviewProvider {
    static var previews: some View {
        addFriend().environmentObject(UserViewModel())
    }
}

extension addFriend {
    private var searchBar: some View {
        HStack{
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search User", text: $userName).foregroundColor(Color.black).disableAutocorrection(true)
            }.padding()
                .background(Color.gray).opacity(0.5)
                .cornerRadius(50)
                .padding(.leading)
            Button{
                userName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
                Task {
                    await vm.findUser(username: userName.lowercased())
                    if vm.searchedUser != nil {
                        showSearchBar.toggle()
                    } else {
                        userNotFound = true
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
