//
//  onboardingVM.swift
//  TennisTracker
//
//  Created by Arman Zadeh-Attar on 2022-12-19.
//

import Foundation

class OnboardingViewModel: ObservableObject {
    @Published var message = ""
    @Published var isSignedIn = false
    
    func register(email: String, password: String, username: String) async -> Bool {
        if await FirebaseManager.shared.validateUsername(username: username.lowercased()) {
            do {
                try await FirebaseManager.shared.auth.createUser(withEmail: email.lowercased(), password: password)
                try await createUser(email: email.lowercased(), username: username)
                return true
            } catch {
                await MainActor.run(body: { [weak self] in
                    self?.message = error.localizedDescription
                })
                return false
            }
        } else {
            await MainActor.run(body: { [weak self] in
                self?.message = "Username already exists!"
            })
            return false
        }
    }
    
    func createUser(email: String, username: String) async throws {
        guard let userID = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["email" : email.lowercased(), "uid": userID, "profilePicUrl" : "", "username" : username.lowercased(), "displayName" : username, "matchesPlayed" : 0, "matchesWon": 0, "trophies" : 0, "friends" : []] as [String : Any]
        do {
            try await FirebaseManager.shared.createUser(userData: userData, userID: userID)
        } catch {
            throw error
        }
    }
    
    func logIn(email: String, password: String) async {
        await MainActor.run(body: {
            self.message = ""
        })
        do {
            try await FirebaseManager.shared.signIn(email: email.lowercased(), password: password)
            await MainActor.run(body: {
                self.isSignedIn = true
            })
        } catch {
            await MainActor.run(body: {
                self.message = ("Unable to sign in: \(error.localizedDescription)")
                self.isSignedIn = false
            })
        }
    }
    
    func resetPassword(email: String) async -> Bool {
        do {
            try await FirebaseManager.shared.auth.sendPasswordReset(withEmail: email.lowercased())
            await MainActor.run(body: {
                self.message = "Password reset email has been sent!"
            })
            return true
        } catch {
            await MainActor.run(body: {
                self.message = error.localizedDescription
            })
            return false
        }
    }
}
