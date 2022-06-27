//
//  userVM.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-05-12.
//

import Foundation
import SwiftUI
import Firebase



class UserViewModel: ObservableObject {
    
    @Published var test = ""
    @Published var user: User?
    @Published var friends: [Friend] = []
    @Published var userSearch: User?
    @Published var isUserFriend = false
    @Published var leaguesIn: [League] = []
    
    init(){
        getCurrentUser()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            self.getFriends()
        }
    }
    
    private func getCurrentUser(){
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        
        
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            guard let data = snapshot?.data() else {return}
            let uid = data["uid"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let username = data["username"] as? String ?? ""
            let profilePicUrl = data["profilePicUrl"] as? String ?? ""
            let displayName = data["displayName"] as? String ?? ""
            let matchesPlayed = data["matchesPlayed"] as? Int ?? 0
            let matchesWon = data["matchesWon"] as? Int ?? 0
            let trophies = data["trophies"] as? Int ?? 0
            let friendsUid = data["friends"] as? [String] ?? []
            self.user = User(uid: uid, email: email, username: username, profilePicUrl: profilePicUrl, displayName: displayName, matchesPlayed: matchesPlayed, matchesWon: matchesWon, trophies: trophies, friendsUid: friendsUid)
        }
    }
    
    private func getFriends() {
        if user?.friendsUid.count ?? 0 > 0{
            for friend in user!.friendsUid {
                FirebaseManager.shared.firestore.collection("users").document(friend).getDocument { snapshot, err in
                    if let err = err {
                        print("ERROR IS: \(err.localizedDescription)")
                        return
                    }
                    guard let data = snapshot?.data() else {return}
                    let uid = data["uid"] as? String ?? ""
                    let username = data["username"] as? String ?? ""
                    let profilePicUrl = data["profilePicUrl"] as? String ?? ""
                    let displayName = data["displayName"] as? String ?? ""
                    let matchesPlayed = data["matchesPlayed"] as? Int ?? 0
                    let matchesWon = data["matchesWon"] as? Int ?? 0
                    let trophies = data["trophies"] as? Int ?? 0
                    
                    let friend = Friend(uid: uid, username: username, profilePicUrl: profilePicUrl, displayName: displayName, matchesPlayed: matchesPlayed, matchesWon: matchesWon, trophies: trophies)
                    
                    self.friends.append(friend)
                }
            }
        }
    }
    
    func findUser(userName: String){
        if userSearch?.uid != ""{
            userSearch = nil
        }
        
        FirebaseManager.shared.firestore.collection("users").whereField("username", isEqualTo: userName).getDocuments { snapshot, err in
            if let err = err{
                print(err.localizedDescription)
                return
            }
            for document in snapshot!.documents{
                let uid = document["uid"] as? String ?? ""
                let email = document["email"] as? String ?? ""
                let username = document["username"] as? String ?? ""
                let profilePicUrl = document["profilePicUrl"] as? String ?? ""
                let displayName = document["displayName"] as? String ?? ""
                let matchesPlayed = document["matchesPlayed"] as? Int ?? 0
                let matchesWon = document["matchesWon"] as? Int ?? 0
                let trophies = document["trophies"] as? Int ?? 0
                let friendsUid = document["friends"] as? [String] ?? []
                
                self.userSearch = User(uid: uid, email: email, username: username, profilePicUrl: profilePicUrl, displayName: displayName, matchesPlayed: matchesPlayed, matchesWon: matchesWon, trophies: trophies, friendsUid: friendsUid)
            }
        }
    }
    
    func addUser(userUid: String){
        if userUid != "" {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        
        FirebaseManager.shared.firestore.collection("users").document(uid).updateData(["friends" : FieldValue.arrayUnion([userUid])])
        
        FirebaseManager.shared.firestore.collection("users").document(userUid).updateData(["friends" : FieldValue.arrayUnion([uid])])
        }
        isUserFriend = true
    }
    
    func friendCheck(friendUid: String){
        
        if user?.friendsUid.count ?? 0 > 0 {
            if user!.friendsUid.contains(where: {$0 == friendUid}) {
                isUserFriend = true
            }
            else {
                isUserFriend = false
            }
        }
    }
}
