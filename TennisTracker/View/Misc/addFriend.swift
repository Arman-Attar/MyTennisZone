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
        }.navigationTitle("Find User")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSearchBar) {
                VStack{
                    backButton.padding()
                    if vm.searchedUser?.uid ?? "" == "" {
                        Spacer()
                        Text("User Not Found")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    else {
                        header
                        statBar
                        add
                    }
                    Spacer()
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
    private var statBar: some View {
        HStack{
            Spacer()
            VStack {
                let userFriends = vm.searchedUser?.friends.count ?? 0
                Text("\(userFriends)")
                    .font(.callout)
                    .fontWeight(.bold)
                Text("Friends")
                    .font(.caption)
            }.padding()
            Spacer()
            VStack {
                Text("\(vm.searchedUser?.matchesPlayed ?? 0)")
                    .font(.callout)
                    .fontWeight(.bold)
                Text("Games")
                    .font(.caption)
            }.padding()
            Spacer()
            VStack {
                if let matchesWon = vm.searchedUser?.matchesWon, let matchesPlayed = vm.searchedUser?.matchesPlayed {
                    let winRate: Double = Double(matchesWon) / Double(matchesPlayed)
                    Text("\(winRate * 100, specifier: "%.2f")")
                        .font(.callout)
                        .fontWeight(.bold)
                }
                Text("Win%")
                    .font(.caption)
            }.padding()
            Spacer()
            VStack {
                Text("\(vm.searchedUser?.trophies ?? 0)")
                    .font(.callout)
                    .fontWeight(.bold)
                Text("Trophies")
                    .font(.caption)
            }.padding()
            Spacer()
        }.padding(.horizontal)
    }
    
    private var header: some View {
        VStack{
            if vm.searchedUser?.profilePicUrl != "" {
                WebImage(url: URL(string: vm.searchedUser?.profilePicUrl ?? ""))
                    .userImageModifier(width: 200, height: 200)
                    .padding()
            }
            
            else {
                Image("profile")
                    .userImageModifier(width: 200, height: 200)
                    .padding()
            }
            Text(vm.searchedUser?.displayName ?? "")
                .font(.title)
                .fontWeight(.bold)
            
            
            Text("@\(vm.searchedUser?.username ?? "")")
                .font(.body)
                .foregroundColor(Color.gray)
        }
        
        
    }
    
    private var add: some View {
        VStack {
            if vm.isFriend {
                HStack {
                    Image(systemName: "person.fill.checkmark").font(.title).foregroundColor(.black)
                    Text("Friend")
                        .font(.title2)
                        .fontWeight(.heavy)
                        .padding()
                        .foregroundColor(.black)
                        .padding()
                    
                }.frame(maxWidth: UIScreen.main.bounds.size.width / 1.25, maxHeight: 50)
                    .overlay(RoundedRectangle(cornerRadius: 100)
                        .stroke(Color.black, lineWidth: 0.8))
                    .padding()
                    .offset(y: 9)
            }
            else{
                Button {
                    Task {
                        await vm.addFriend(friendID: userName)
                    }
                } label: {
                    HStack {
                        Image(systemName: "person.fill.badge.plus").font(.title).foregroundColor(.black)
                        Text("Add")
                            .font(.title2)
                            .fontWeight(.heavy)
                            .padding()
                            .foregroundColor(.black)
                            .padding()
                        
                    }.frame(maxWidth: UIScreen.main.bounds.size.width / 1.25, maxHeight: 50)
                        .overlay(RoundedRectangle(cornerRadius: 100)
                            .stroke(Color.black, lineWidth: 0.8))
                        .padding()
                        .offset(y: 9)
                }
            }
        }
        
    }
    
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
    
    private var backButton: some View {
        VStack{
            Button {
                showSearchBar.toggle()
            } label: {
                HStack{
                    Image(systemName: "arrow.left")
                    Text("Back")
                    Spacer()
                }.padding()
            }
        }
    }
}
