//
//  FriendSummaryView.swift
//  MyTennisZone
//
//  Created by Arman Zadeh-Attar on 2022-12-24.
//

import SwiftUI
import SDWebImageSwiftUI

struct FriendSummaryView: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: UserViewModel
    
    var body: some View {
        NavigationView {
            VStack{
                header
                statBar
                addButton
                Spacer()
            }
            .navigationTitle("Add Friend")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                }
            }
        }
    }
}

struct FriendSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        FriendSummaryView().environmentObject(UserViewModel())
    }
}

extension FriendSummaryView {
    private var header: some View {
        VStack{
            if let user = vm.searchedUser {
                if user.profilePicUrl != "" {
                    WebImage(url: URL(string: user.profilePicUrl))
                        .userImageModifier(width: 200, height: 200)
                        .padding()
                }
                else {
                    Image("profile")
                        .userImageModifier(width: 200, height: 200)
                        .padding()
                }
                Text(user.displayName)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("@\(user.username)")
                    .font(.body)
                    .foregroundColor(Color.gray)
            }
        }
    }
    private var statBar: some View {
        HStack{
            if let user = vm.searchedUser {
                Spacer()
                VStack {
                    Text("\(user.friends.count)")
                        .font(.callout)
                        .fontWeight(.bold)
                    Text("Friends")
                        .font(.caption)
                }.padding()
                Spacer()
                VStack {
                    Text("\(user.matchesPlayed)")
                        .font(.callout)
                        .fontWeight(.bold)
                    Text("Games")
                        .font(.caption)
                }.padding()
                Spacer()
                VStack {
                    let winRate: Double = Double(user.matchesWon) / Double(user.matchesPlayed)
                    Text("\(winRate * 100, specifier: "%.1f")")
                        .font(.callout)
                        .fontWeight(.bold)
                    
                    Text("Win%")
                        .font(.caption)
                }.padding()
                Spacer()
                VStack {
                    Text("\(user.trophies)")
                        .font(.callout)
                        .fontWeight(.bold)
                    Text("Trophies")
                        .font(.caption)
                }.padding()
                Spacer()
            }
        }.padding(.horizontal)
    }
    private var backButton: some View {
        VStack{
            Button {
                dismiss()
            } label: {
                HStack{
                    Image(systemName: "arrow.left")
                    Text("Back")
                    Spacer()
                }.padding()
            }
        }
    }
    private var addButton: some View {
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
                        await vm.addFriend()
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
}
