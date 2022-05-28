//
//  addFriend.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-15.
//

import SwiftUI
import SDWebImageSwiftUI

struct addFriend: View {
    @ObservedObject private var vm = UserViewModel()
    @State var userName = ""
    @State var showSearchBar = false
    //@State var addButton = false
    
    var body: some View {
        NavigationView {
                VStack{
                    ForEach(0..<10) { rows in
                        Divider().padding()
                    }
                    Spacer()
                    Divider().padding()
                    TextField(" Enter Username", text: $userName)
                        .padding()
                            .frame(width: UIScreen.main.bounds.size.width - 50, height: 50)
                            .foregroundColor(Color.black)
                            .background(Color.gray.opacity(0.4))
                            .cornerRadius(10)
                    Button {
                        vm.findUser(userName: userName)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                        vm.friendCheck(friendUid: vm.userSearch?.uid ?? "")
                        showSearchBar.toggle()
                        }
                    } label: {
                        Text("Find")
                            .font(.title2)
                            .fontWeight(.heavy)
                            .padding()
                            .foregroundColor(.black)
                            .frame(maxWidth: UIScreen.main.bounds.size.width / 2, maxHeight: 20)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 100)
                                .stroke(Color.black, lineWidth: 0.8))
                            .padding()
                            .offset(y: 9)                            }
                }.navigationTitle("Find User")
            }.sheet(isPresented: $showSearchBar) {
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
                    header
                    statBar
                    add
                    Spacer()
                    Divider().padding()
                }
            }
            
        }
    }

struct addFriend_Previews: PreviewProvider {
    static var previews: some View {
        addFriend()
    }
}

extension addFriend {
    private var statBar: some View {
        HStack{
            Spacer()
            VStack {
                Text("\(vm.userSearch?.friendsUid.count ?? 0)")
                    .font(.callout)
                    .fontWeight(.bold)
                Text("Friends")
                    .font(.caption)
            }.padding()
            Spacer()
            VStack {
                Text("\(vm.userSearch?.matchesPlayed ?? 0)")
                    .font(.callout)
                    .fontWeight(.bold)
                Text("Games")
                    .font(.caption)
            }.padding()
            Spacer()
            VStack {
                Text("\(vm.userSearch?.matchesWon ?? 0)")
                    .font(.callout)
                    .fontWeight(.bold)
                Text("Win%")
                    .font(.caption)
            }.padding()
            Spacer()
            VStack {
                Text("\(vm.userSearch?.trophies ?? 0)")
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
                if vm.userSearch?.profilePicUrl != "" {
                    WebImage(url: URL(string: vm.userSearch?.profilePicUrl ?? ""))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding()
                }
                
                else {
                    Image("profile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .shadow(radius: 20)
                        .padding()
                }
            Text(vm.userSearch?.displayName ?? "")
                .font(.title)
                .fontWeight(.bold)
            
            
            Text("@\(vm.userSearch?.username ?? "")")
                .font(.body)
                .foregroundColor(Color.gray)
            }

         
    }
    
    private var add: some View {
        VStack {
            if vm.isUserFriend {
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
                vm.addUser(userUid: vm.userSearch?.uid ?? "")
                //addButton.toggle()
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
}
